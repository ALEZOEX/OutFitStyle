package main

import (
	"bufio"
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"os"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

type NDItem struct {
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
}

func main() {
	filePath := flag.String("file", "", "Path to ndjson file")
	dsn := flag.String("dsn", "", "Database URL")
	flag.Parse()

	if *filePath == "" || *dsn == "" {
		fmt.Println("Usage: go run main.go -file data.ndjson -dsn postgres://...")
		os.Exit(1)
	}

	ctx := context.Background()
	db, err := pgxpool.New(ctx, *dsn)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	file, err := os.Open(*filePath)
	if err != nil {
		panic(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	count := 0

	for scanner.Scan() {
		var it NDItem
		if err := json.Unmarshal(scanner.Bytes(), &it); err != nil {
			fmt.Println("Skipping bad line:", err)
			continue
		}

		// Fix category mapping if needed (apparel -> upper/lower/outerwear logic or manual fix)
		// For MVP assuming NDJSON has correct categories or we map 'apparel' -> 'upper' as default
		if it.Category == "apparel" {
			it.Category = "upper" // Simplification
		}

		id := uuid.New()
		_, err := db.Exec(ctx, `
INSERT INTO clothing_items (
id, name, category, subcategory, gender, style,
formality_level, warmth_level, min_temp, max_temp,
season, base_colour, usage, materials, fit, pattern,
icon_emoji, source, is_owned, is_active, created_at
) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, 'synthetic', false, true, NOW())
ON CONFLICT DO NOTHING
`, id, it.Name, it.Category, it.Subcategory, it.Gender, it.Style,
			it.Formality, it.Warmth, it.MinTemp, it.MaxTemp,
			it.Season, it.BaseColour, []string{it.Usage}, it.Materials, it.Fit, it.Pattern,
			it.IconEmoji)

		if err != nil {
			fmt.Printf("Failed to insert %s: %v\n", it.Name, err)
		} else {
			count++
		}
	}
	fmt.Printf("Imported %d items\n", count)
}
