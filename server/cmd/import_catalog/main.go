package main

import (
	"bufio"
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"math"
	"os"
	"strings"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type NDItem struct {
	ID          int64    `json:"id"`
	Name        string   `json:"name"`
	Category    string   `json:"category"`
	Subcategory string   `json:"subcategory"`
	Gender      string   `json:"gender"`
	Style       string   `json:"style"`
	Formality   int      `json:"formality_level"`
	Warmth      int      `json:"warmth_level"`
	MinTemp     int      `json:"min_temp"`
	MaxTemp     int      `json:"max_temp"`
	Season      string   `json:"season"`
	BaseColour  string   `json:"base_colour"`
	Usage       string   `json:"usage"`
	Materials   []string `json:"materials"`
	Fit         string   `json:"fit"`
	Pattern     string   `json:"pattern"`
	IconEmoji   string   `json:"icon_emoji"`
	Source      string   `json:"source"`
	IsOwned     bool     `json:"is_owned"`
}

func norm(s string) string {
	return strings.ToLower(strings.TrimSpace(s))
}

func clampInt(v, lo, hi int) int {
	if v < lo {
		return lo
	}
	if v > hi {
		return hi
	}
	return v
}

var allowedStyle = map[string]bool{
	"casual": true, "sport": true, "street": true, "classic": true,
	"business": true, "smart_casual": true, "outdoor": true,
}
var allowedUsage = map[string]bool{
	"daily": true, "work": true, "formal": true, "sport": true,
	"outdoor": true, "travel": true, "party": true,
}
var allowedSeason = map[string]bool{
	"winter": true, "spring": true, "summer": true, "autumn": true, "all": true,
}
var allowedFit = map[string]bool{
	"slim": true, "regular": true, "relaxed": true, "oversized": true,
}
var allowedPattern = map[string]bool{
	"solid": true, "striped": true, "checked": true, "printed": true, "camo": true,
}
var allowedSource = map[string]bool{
	"synthetic": true, "user": true, "partner": true, "manual": true,
}
var allowedColour = map[string]bool{
	"black": true, "white": true, "gray": true, "navy": true, "beige": true, "brown": true,
	"green": true, "blue": true, "red": true, "pink": true, "yellow": true, "orange": true, "purple": true,
}

// --- mappers под CHECK constraints ---

func mapStyle(raw string) string {
	s := norm(raw)
	if allowedStyle[s] {
		return s
	}
	// MVP: всё неизвестное -> casual (например ethnic)
	return "casual"
}

func mapUsage(raw string) string {
	s := norm(raw)
	// ndjson часто содержит casual -> в БД такого нет
	if s == "casual" {
		return "daily"
	}
	if allowedUsage[s] {
		return s
	}
	return "daily"
}

func mapSeason(raw string) string {
	s := norm(raw)
	if s == "fall" {
		s = "autumn"
	}
	if allowedSeason[s] {
		return s
	}
	return "all"
}

// если вы разрешили men/women/unisex в clothing_items.gender
func mapGender(raw string) string {
	g := norm(raw)
	switch g {
	case "men", "male", "m":
		return "men"
	case "women", "female", "f":
		return "women"
	case "unisex", "":
		return "unisex"
	default:
		return "unisex"
	}
}

func mapSource(raw string) string {
	s := norm(raw)
	if allowedSource[s] {
		return s
	}
	return "synthetic"
}

func mapFit(raw string) any {
	s := norm(raw)
	if s == "" {
		return nil
	}
	if allowedFit[s] {
		return s
	}
	return nil
}

func mapPattern(raw string) any {
	s := norm(raw)
	if s == "" {
		return nil
	}
	if allowedPattern[s] {
		return s
	}
	return nil
}

func mapColour(raw string) any {
	s := norm(raw)
	if s == "" {
		return nil
	}
	switch s {
	case "navy blue":
		s = "navy"
	case "grey":
		s = "gray"
	case "silver":
		// в enum нет silver -> для MVP маппим в gray
		s = "gray"
	}
	if allowedColour[s] {
		return s
	}
	return nil
}

// category для БД: outerwear/upper/lower/footwear/accessory
func mapCategory(catRaw, subRaw string) string {
	cat := norm(catRaw)
	sub := norm(subRaw)

	if cat == "accessories" || cat == "accessory" {
		return "accessory"
	}

	// mvp: простая классификация подкатегорий
	footwearSubs := map[string]bool{"shoes": true, "sneakers": true, "boots": true, "sandals": true, "loafers": true, "oxford": true}
	outerSubs := map[string]bool{"coat": true, "jacket": true, "parka": true, "raincoat": true, "puffer": true}
	lowerSubs := map[string]bool{"jeans": true, "trackpants": true, "pants": true, "trousers": true, "shorts": true, "skirt": true}

	if footwearSubs[sub] {
		return "footwear"
	}
	if outerSubs[sub] {
		return "outerwear"
	}
	if lowerSubs[sub] {
		return "lower"
	}

	if cat == "apparel" {
		return "upper"
	}

	switch cat {
	case "outerwear", "upper", "lower", "footwear", "accessory":
		return cat
	}

	return "upper"
}

// --- external_id поддержка (отрицательные id) ---
func toExternalID(id int64, source string) int64 {
	src := mapSource(source)
	abs := int64(math.Abs(float64(id)))
	if abs == 0 {
		return 0
	}
	if src == "synthetic" {
		return -abs
	}
	return abs
}

func columnExists(ctx context.Context, db *pgxpool.Pool, table, column string) (bool, error) {
	var exists bool
	err := db.QueryRow(ctx, `
SELECT EXISTS (
  SELECT 1
  FROM information_schema.columns
  WHERE table_schema='public'
    AND table_name=$1
    AND column_name=$2
)`, table, column).Scan(&exists)
	return exists, err
}

func main() {
	filePath := flag.String("file", "", "Path to ndjson file")
	dsn := flag.String("dsn", "", "Database URL")
	batchSize := flag.Int("batch", 300, "Batch size")
	flag.Parse()

	if *filePath == "" || *dsn == "" {
		fmt.Println("Usage: go run main.go -file data.ndjson -dsn postgres://... [-batch 300]")
		os.Exit(1)
	}

	ctx := context.Background()
	db, err := pgxpool.New(ctx, *dsn)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	hasExternalID, err := columnExists(ctx, db, "clothing_items", "external_id")
	if err != nil {
		panic(err)
	}
	if hasExternalID {
		fmt.Println("Detected clothing_items.external_id -> will UPSERT by external_id (supports negative ids).")
	} else {
		fmt.Println("No clothing_items.external_id -> will UPSERT by deterministic UUID from NDJSON id.")
	}

	file, err := os.Open(*filePath)
	if err != nil {
		panic(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	// увеличиваем лимит строки сканера (на случай длинных json)
	buf := make([]byte, 0, 1024*1024)
	scanner.Buffer(buf, 10*1024*1024)

	seenSpecs := make(map[string]bool)

	var batch pgx.Batch
	pending := 0
	imported := 0
	skipped := 0

	flush := func() {
		if pending == 0 {
			return
		}
		tx, err := db.Begin(ctx)
		if err != nil {
			panic(err)
		}
		defer func() { _ = tx.Rollback(ctx) }()

		br := tx.SendBatch(ctx, &batch)
		if err := br.Close(); err != nil {
			panic(err)
		}
		if err := tx.Commit(ctx); err != nil {
			panic(err)
		}

		batch = pgx.Batch{}
		pending = 0
	}

	for scanner.Scan() {
		var it NDItem
		if err := json.Unmarshal(scanner.Bytes(), &it); err != nil {
			skipped++
			continue
		}

		name := strings.TrimSpace(it.Name)
		if name == "" || it.ID == 0 {
			skipped++
			continue
		}

		cat := mapCategory(it.Category, it.Subcategory)
		sub := norm(it.Subcategory)
		if sub == "" {
			skipped++
			continue
		}

		source := mapSource(it.Source)
		gender := mapGender(it.Gender)
		style := mapStyle(it.Style)
		usage := mapUsage(it.Usage)
		season := mapSeason(it.Season)

		formality := clampInt(it.Formality, 1, 5)
		warmth := clampInt(it.Warmth, 1, 10)

		// temp check
		minTemp := it.MinTemp
		maxTemp := it.MaxTemp
		if minTemp > maxTemp {
			minTemp, maxTemp = maxTemp, minTemp
		}

		baseColour := mapColour(it.BaseColour) // nil или string
		fit := mapFit(it.Fit)                  // nil или string
		pattern := mapPattern(it.Pattern)      // nil или string

		materials := it.Materials
		if materials == nil {
			materials = []string{}
		}

		// FK: гарантируем subcategory_specs
		specKey := cat + "|" + sub
		if !seenSpecs[specKey] {
			seenSpecs[specKey] = true

			// warmth_min 1..10
			warmthMin := clampInt(warmth, 1, 10)

			batch.Queue(`
INSERT INTO subcategory_specs (
  category, subcategory,
  warmth_min, temp_min_reco, temp_max_reco,
  rain_ok, snow_ok, wind_ok
) VALUES ($1,$2,$3,$4,$5, true,true,true)
ON CONFLICT (category, subcategory) DO NOTHING
`, cat, sub, warmthMin, minTemp, maxTemp)

			pending++
		}

		// вставка в clothing_items
		if hasExternalID {
			extID := toExternalID(it.ID, source)
			if extID == 0 {
				skipped++
				continue
			}

			batch.Queue(`
INSERT INTO clothing_items (
  external_id,
  name, category, subcategory,
  gender, style, usage, season,
  base_colour,
  formality_level, warmth_level,
  min_temp, max_temp,
  materials, fit, pattern,
  icon_emoji,
  source, is_owned, is_active
) VALUES (
  $1,
  $2,$3,$4,
  $5,$6,$7,$8,
  $9,
  $10,$11,
  $12,$13,
  $14,$15,$16,
  $17,
  $18,$19,true
)
ON CONFLICT (external_id) DO UPDATE SET
  name=EXCLUDED.name,
  category=EXCLUDED.category,
  subcategory=EXCLUDED.subcategory,
  gender=EXCLUDED.gender,
  style=EXCLUDED.style,
  usage=EXCLUDED.usage,
  season=EXCLUDED.season,
  base_colour=EXCLUDED.base_colour,
  formality_level=EXCLUDED.formality_level,
  warmth_level=EXCLUDED.warmth_level,
  min_temp=EXCLUDED.min_temp,
  max_temp=EXCLUDED.max_temp,
  materials=EXCLUDED.materials,
  fit=EXCLUDED.fit,
  pattern=EXCLUDED.pattern,
  icon_emoji=EXCLUDED.icon_emoji,
  source=EXCLUDED.source,
  is_owned=EXCLUDED.is_owned,
  updated_at=now()
`, extID,
				name, cat, sub,
				gender, style, usage, season,
				baseColour,
				formality, warmth,
				minTemp, maxTemp,
				materials, fit, pattern,
				it.IconEmoji,
				source, false, // synthetic/user catalog item по умолчанию не owned
			)

		} else {
			itemUUID := uuid.NewSHA1(uuid.Nil, []byte(fmt.Sprintf("%s:%d", source, it.ID)))

			batch.Queue(`
INSERT INTO clothing_items (
  id,
  name, category, subcategory,
  gender, style, usage, season,
  base_colour,
  formality_level, warmth_level,
  min_temp, max_temp,
  materials, fit, pattern,
  icon_emoji,
  source, is_owned, is_active
) VALUES (
  $1,
  $2,$3,$4,
  $5,$6,$7,$8,
  $9,
  $10,$11,
  $12,$13,
  $14,$15,$16,
  $17,
  $18,$19,true
)
ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name,
  category=EXCLUDED.category,
  subcategory=EXCLUDED.subcategory,
  gender=EXCLUDED.gender,
  style=EXCLUDED.style,
  usage=EXCLUDED.usage,
  season=EXCLUDED.season,
  base_colour=EXCLUDED.base_colour,
  formality_level=EXCLUDED.formality_level,
  warmth_level=EXCLUDED.warmth_level,
  min_temp=EXCLUDED.min_temp,
  max_temp=EXCLUDED.max_temp,
  materials=EXCLUDED.materials,
  fit=EXCLUDED.fit,
  pattern=EXCLUDED.pattern,
  icon_emoji=EXCLUDED.icon_emoji,
  source=EXCLUDED.source,
  is_owned=EXCLUDED.is_owned,
  updated_at=now()
`, itemUUID,
				name, cat, sub,
				gender, style, usage, season,
				baseColour,
				formality, warmth,
				minTemp, maxTemp,
				materials, fit, pattern,
				it.IconEmoji,
				source, false,
			)
		}

		pending++
		imported++

		if pending >= *batchSize {
			flush()
		}
	}

	if err := scanner.Err(); err != nil {
		panic(err)
	}

	flush()
	fmt.Printf("Imported/Upserted: %d, skipped: %d\n", imported, skipped)
}
