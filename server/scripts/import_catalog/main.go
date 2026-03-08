package main

import (
	"bufio"
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"math"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/google/uuid"

	"outfitstyle/server/internal/catalog"
	"outfitstyle/server/internal/ml"
)

type NDItem struct {
	ID            int64    `json:"id"`
	Name          string   `json:"name"`
	Category      string   `json:"category"`
	Subcategory   string   `json:"subcategory"`
	Gender        string   `json:"gender"`
	Style         string   `json:"style"`
	Formality     int      `json:"formality_level"`
	Warmth        int      `json:"warmth_level"`
	MinTemp       int      `json:"min_temp"`
	MaxTemp       int      `json:"max_temp"`
	Season        string   `json:"season"`
	BaseColour    string   `json:"base_colour"`
	Usage         string   `json:"usage"`
	Materials     []string `json:"materials"`
	Fit           string   `json:"fit"`
	Pattern       string   `json:"pattern"`
	IconEmoji     string   `json:"icon_emoji"`
	Source        string   `json:"source"`
	IsOwned       bool     `json:"is_owned"`
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

// БД принимает только эти значения
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

// нормализация цветов из ваших ndjson (Navy Blue, Grey, Silver)
func mapColour(raw string) *string {
	s := norm(raw)
	if s == "" {
		return nil
	}

	// часто встречающиеся случаи
	switch s {
	case "navy blue":
		s = "navy"
	case "grey":
		s = "gray"
	case "silver":
		// в вашем enum нет silver -> для MVP маппим в gray
		s = "gray"
	}

	if allowedColour[s] {
		return &s
	}
	// если не можем — ставим NULL, чтобы не падать на CHECK
	return nil
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

func mapStyle(raw string) string {
	s := norm(raw)
	if allowedStyle[s] {
		return s
	}
	// для MVP всё неизвестное -> casual (например ethnic)
	return "casual"
}

func mapUsage(raw string) string {
	s := norm(raw)
	// ваш ndjson часто содержит "casual" -> в БД такого нет
	if s == "casual" {
		return "daily"
	}
	if allowedUsage[s] {
		return s
	}
	// fallback
	return "daily"
}

// ваш clothing_items.gender сейчас CHECK (gender IN ('unisex'))
func mapGender(_ string) string {
	return "unisex"
}

// category for БД: outerwear/upper/lower/footwear/accessory
// DEPRECATED: This function is replaced by CategoryMapper
// Kept for reference only - DO NOT USE
func mapCategoryOld(catRaw, subRaw string) string {
	cat := norm(catRaw)
	sub := norm(subRaw)

	// accessories -> accessory
	if cat == "accessories" || cat == "accessory" {
		return "accessory"
	}

	// по подкатегории определяем верх/низ/обувь/верхняя одежда
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

	// apparel -> upper по умолчанию
	if cat == "apparel" {
		return "upper"
	}

	// если вдруг уже каноника
	switch cat {
	case "outerwear", "upper", "lower", "footwear", "accessory":
		return cat
	}

	// fallback
	return "upper"
}

func mapFit(raw string) *string {
	s := norm(raw)
	if s == "" {
		return nil
	}
	if allowedFit[s] {
		return &s
	}
	return nil
}

func mapPattern(raw string) *string {
	s := norm(raw)
	if s == "" {
		return nil
	}
	if allowedPattern[s] {
		return &s
	}
	return nil
}

func mapSource(raw string) string {
	s := norm(raw)
	if allowedSource[s] {
		return s
	}
	return "synthetic"
}

// external_id: synthetic -> отрицательный
func toExternalID(id int64, source string) int64 {
	src := mapSource(source)
	if id == 0 {
		return 0
	}
	abs := int64(math.Abs(float64(id)))
	if src == "synthetic" {
		return -abs
	}
	return abs
}

func main() {
	filePath := flag.String("file", "", "Path to ndjson file")
	dsn := flag.String("dsn", "", "Database URL")
	batchSize := flag.Int("batch", 300, "Batch size")
	configPath := flag.String("config", "server/config/category_mapping.json", "Path to category mapping config")
	reportsDir := flag.String("reports", "server/validation_reports", "Directory for validation reports")
	mlServiceURL := flag.String("ml-url", "", "ML service URL (optional, e.g., http://localhost:8001)")
	flag.Parse()

	if *filePath == "" || *dsn == "" {
		fmt.Println("Usage: go run main.go -file data.ndjson -dsn postgres://... [-batch 300] [-config path] [-reports dir]")
		os.Exit(1)
	}

	ctx := context.Background()
	db, err := pgxpool.New(ctx, *dsn)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to connect to database: %v\n", err)
		os.Exit(1)
	}
	defer db.Close()

	// Initialize CategoryMapper with optional ML client
	var mlClient catalog.MLClassifierClient
	if *mlServiceURL != "" {
		fmt.Printf("Initializing ML classifier client with URL: %s\n", *mlServiceURL)
		mlClient = catalog.NewMLClassifierAdapter(ml.NewClassifierClient(*mlServiceURL))
	} else {
		fmt.Println("ML service URL not provided, using config-based mapping only")
	}

	categoryMapper, err := catalog.NewCategoryMapper(*configPath, mlClient)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to initialize category mapper: %v\n", err)
		os.Exit(1)
	}

	// Initialize ImportValidator
	validator := catalog.NewImportValidator(categoryMapper)

	// Create import metadata record
	importID := uuid.New()
	startTime := time.Now()
	_, err = db.Exec(ctx, `
		INSERT INTO import_metadata (id, filename, started_at, status)
		VALUES ($1, $2, $3, 'running')
	`, importID, filepath.Base(*filePath), startTime)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to create import metadata: %v\n", err)
		os.Exit(1)
	}

	file, err := os.Open(*filePath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to open file: %v\n", err)
		updateImportStatus(ctx, db, importID, "failed", 0, 0, "")
		os.Exit(1)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	// увеличим лимит строки (на случай длинных json)
	buf := make([]byte, 0, 1024*1024)
	scanner.Buffer(buf, 10*1024*1024)

	// чтобы не делать insert specs по одной паре миллион раз
	seenSpecs := make(map[string]bool)

	var batch pgx.Batch
	pending := 0
	total := 0
	skipped := 0

	// Track ML classification statistics
	mlClassified := 0
	mlHighConfidence := 0
	mlLowConfidence := 0

	// Collect items for validation
	var validationItems []*catalog.ClothingItem

	flush := func() {
		if pending == 0 {
			return
		}
		tx, err := db.Begin(ctx)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Failed to begin transaction: %v\n", err)
			updateImportStatus(ctx, db, importID, "failed", total, skipped, "")
			os.Exit(1)
		}
		defer func() { _ = tx.Rollback(ctx) }()

		br := tx.SendBatch(ctx, &batch)
		if err := br.Close(); err != nil {
			_ = tx.Rollback(ctx)
			fmt.Fprintf(os.Stderr, "Failed to execute batch: %v\n", err)
			updateImportStatus(ctx, db, importID, "failed", total, skipped, "")
			os.Exit(1)
		}
		if err := tx.Commit(ctx); err != nil {
			fmt.Fprintf(os.Stderr, "Failed to commit transaction: %v\n", err)
			updateImportStatus(ctx, db, importID, "failed", total, skipped, "")
			os.Exit(1)
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

		// нормализуем
		sub := norm(it.Subcategory)
		if sub == "" {
			skipped++
			continue
		}

		// Create ClothingItem for classification
		clothingItem := &catalog.ClothingItem{
			Name:        it.Name,
			Subcategory: it.Subcategory,
			Materials:   it.Materials,
			Style:       it.Style,
		}

		// Use MapCategoryWithML for ML-enhanced classification
		cat, confidence, err := categoryMapper.MapCategoryWithML(ctx, clothingItem)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error mapping category for item '%s': %v\n", it.Name, err)
			skipped++
			continue
		}

		// Determine classification source based on confidence
		var classificationSource string
		var confidencePtr *float64
		if confidence > 0.8 {
			classificationSource = "ml_auto"
			confidencePtr = &confidence
			mlClassified++
			mlHighConfidence++
		} else if confidence >= 0.5 {
			classificationSource = "ml_flagged"
			confidencePtr = &confidence
			mlClassified++
			mlLowConfidence++
		} else {
			// confidence == 0 means config-based mapping
			classificationSource = "mapping"
			confidencePtr = nil
		}

		// Collect item for validation
		validationItems = append(validationItems, clothingItem)

		// subcategory_specs: upsert (чтобы FK не падал)
		specKey := cat + "|" + sub
		if !seenSpecs[specKey] {
			seenSpecs[specKey] = true

			warmthMin := clampInt(it.Warmth, 1, 10)
			tmin := it.MinTemp
			tmax := it.MaxTemp
			if tmin > tmax {
				tmin, tmax = tmax, tmin
			}

			batch.Queue(`
INSERT INTO subcategory_specs (
  category, subcategory,
  warmth_min, temp_min_reco, temp_max_reco,
  rain_ok, snow_ok, wind_ok
) VALUES ($1,$2,$3,$4,$5, true,true,true)
ON CONFLICT (category, subcategory) DO NOTHING
`, cat, sub, warmthMin, tmin, tmax)

			pending++
		}

		extID := toExternalID(it.ID, it.Source)
		if extID == 0 {
			// без external_id мы не обеспечим идемпотентность
			skipped++
			continue
		}

		name := strings.TrimSpace(it.Name)
		if name == "" {
			skipped++
			continue
		}

		style := mapStyle(it.Style)
		usage := mapUsage(it.Usage)
		season := mapSeason(it.Season)
		gender := mapGender(it.Gender)

		formality := clampInt(it.Formality, 1, 5)
		warmth := clampInt(it.Warmth, 1, 10)

		baseColour := mapColour(it.BaseColour)
		fit := mapFit(it.Fit)
		pattern := mapPattern(it.Pattern)

		source := mapSource(it.Source)

		// для synthetic запрещаем is_owned=true (просто на всякий)
		isOwned := it.IsOwned
		if source == "synthetic" {
			isOwned = false
		}

		materials := it.Materials
		if materials == nil {
			materials = []string{}
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
  source, is_owned, is_active,
  classification_source, classification_confidence
) VALUES (
  $1,
  $2,$3,$4,
  $5,$6,$7,$8,
  $9,
  $10,$11,
  $12,$13,
  $14,$15,$16,
  $17,
  $18,$19,true,
  $20,$21
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
  classification_source=EXCLUDED.classification_source,
  classification_confidence=EXCLUDED.classification_confidence
`, extID,
			name, cat, sub,
			gender, style, usage, season,
			baseColour,
			formality, warmth,
			it.MinTemp, it.MaxTemp,
			materials, fit, pattern,
			it.IconEmoji,
			source, isOwned,
			classificationSource, confidencePtr,
		)

		pending++
		total++

		if pending >= *batchSize {
			flush()
		}
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "Scanner error: %v\n", err)
		updateImportStatus(ctx, db, importID, "failed", total, skipped, "")
		os.Exit(1)
	}

	flush()

	// Generate validation report
	fmt.Println("Generating validation report...")
	report := validator.ValidateBatch(ctx, validationItems)

	// Add ML classification statistics to the report
	report.MLClassified = mlClassified
	report.MLHighConfidence = mlHighConfidence
	report.MLLowConfidence = mlLowConfidence

	reportPath := catalog.GenerateReportPath(*reportsDir, startTime)
	if err := validator.GenerateReport(report, reportPath); err != nil {
		fmt.Fprintf(os.Stderr, "Warning: Failed to generate validation report: %v\n", err)
		// Don't fail the import, just log the warning
	} else {
		fmt.Printf("Validation report saved to: %s\n", reportPath)
	}

	// Update import metadata with completion status
	updateImportStatus(ctx, db, importID, "completed", total, skipped, reportPath)

	fmt.Printf("Import completed successfully!\n")
	fmt.Printf("Imported/Upserted: %d items, skipped: %d\n", total, skipped)
	fmt.Printf("Fallback usage: %.2f%% (%d items)\n", report.FallbackPercent, report.FallbackCount)
	fmt.Printf("Unknown subcategories: %d\n", len(report.UnknownSubcats))

	// Log ML classification statistics
	if mlClassified > 0 {
		fmt.Printf("\nML Classification Statistics:\n")
		fmt.Printf("  Total ML classified: %d items (%.2f%%)\n", mlClassified, float64(mlClassified)/float64(total)*100)
		fmt.Printf("  High confidence (>0.8): %d items\n", mlHighConfidence)
		fmt.Printf("  Low confidence (0.5-0.8): %d items (flagged for review)\n", mlLowConfidence)
	} else {
		fmt.Printf("\nML Classification: Not used (ML service unavailable or all items mapped via config)\n")
	}

	if len(report.Errors) > 0 {
		fmt.Printf("\nErrors encountered: %d\n", len(report.Errors))
		for _, errMsg := range report.Errors {
			fmt.Printf("  - %s\n", errMsg)
		}
	}

	if len(report.Warnings) > 0 {
		fmt.Printf("\nWarnings: %d\n", len(report.Warnings))
		for _, warnMsg := range report.Warnings {
			fmt.Printf("  - %s\n", warnMsg)
		}
	}
}

// updateImportStatus updates the import_metadata record with completion status
func updateImportStatus(ctx context.Context, db *pgxpool.Pool, importID uuid.UUID, status string, totalItems, skippedItems int, reportPath string) {
	_, err := db.Exec(ctx, `
		UPDATE import_metadata
		SET completed_at = $1,
		    status = $2,
		    total_items = $3,
		    successful_items = $4,
		    skipped_items = $5,
		    validation_report_path = $6
		WHERE id = $7
	`, time.Now(), status, totalItems, totalItems-skippedItems, skippedItems, reportPath, importID)

	if err != nil {
		fmt.Fprintf(os.Stderr, "Warning: Failed to update import metadata: %v\n", err)
	}
}
