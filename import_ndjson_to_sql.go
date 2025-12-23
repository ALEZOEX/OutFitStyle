package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"strings"
)

type Item struct {
	Name             string   `json:"name"`
	Category         string   `json:"category"`
	Subcategory      string   `json:"subcategory"`
	Gender           string   `json:"gender"`
	Style            string   `json:"style"`
	FormalityLevel   int      `json:"formality_level"`
	WarmthLevel      int      `json:"warmth_level"`
	MinTemp          int      `json:"min_temp"`
	MaxTemp          int      `json:"max_temp"`
	Season           string   `json:"season"`
	BaseColour       string   `json:"base_colour"`
	Usage            string   `json:"usage"`
	Materials        []string `json:"materials"`
	Fit              string   `json:"fit"`
	Pattern          string   `json:"pattern"`
	IconEmoji        string   `json:"icon_emoji"`
	Source           string   `json:"source"`
	IsOwned          bool     `json:"is_owned"`
}

func main() {
	file, err := os.Open("basic_catalog.ndjson")
	if err != nil {
		fmt.Printf("Error opening file: %v\n", err)
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)

	fmt.Println("-- Generated SQL from NDJSON")
	fmt.Println("BEGIN;")
	
	for scanner.Scan() {
		var item Item
		err := json.Unmarshal(scanner.Bytes(), &item)
		if err != nil {
			fmt.Printf("-- Error parsing JSON: %v\n", err)
			continue
		}

		// Escape single quotes in text fields
		name := strings.ReplaceAll(item.Name, "'", "''")
		category := strings.ReplaceAll(item.Category, "'", "''")
		subcategory := strings.ReplaceAll(item.Subcategory, "'", "''")
		gender := strings.ReplaceAll(item.Gender, "'", "''")
		style := strings.ReplaceAll(item.Style, "'", "''")
		season := strings.ReplaceAll(item.Season, "'", "''")
		baseColour := strings.ReplaceAll(item.BaseColour, "'", "''")
		// Для поля usage формируем массив: если это строка - оборачиваем в фигурные скобки как массив
		usageArray := fmt.Sprintf("{%s}", item.Usage)
		fit := strings.ReplaceAll(item.Fit, "'", "''")
		pattern := strings.ReplaceAll(item.Pattern, "'", "''")
		iconEmoji := strings.ReplaceAll(item.IconEmoji, "'", "''")
		source := strings.ReplaceAll(item.Source, "'", "''")

		materialsJSON := fmt.Sprintf("{%s}", strings.Join(quoteSlice(item.Materials), ","))

		sql := fmt.Sprintf("INSERT INTO clothing_items (name, category, subcategory, gender, style, formality_level, warmth_level, min_temp, max_temp, season, base_colour, usage, materials, fit, pattern, icon_emoji, source, is_owned, is_active, created_at) VALUES ('%s', '%s', '%s', '%s', '%s', %d, %d, %d, %d, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', %t, true, NOW());",
			name, category, subcategory, gender, style, item.FormalityLevel, item.WarmthLevel, item.MinTemp, item.MaxTemp,
			season, baseColour, usageArray, materialsJSON, fit, pattern, iconEmoji, source, item.IsOwned)
		
		fmt.Println(sql)
	}

	fmt.Println("COMMIT;")
	
	if err := scanner.Err(); err != nil {
		fmt.Printf("Error reading file: %v\n", err)
	}
}

func quoteSlice(slice []string) []string {
	result := make([]string, len(slice))
	for i, s := range slice {
		result[i] = fmt.Sprintf(`"%s"`, strings.ReplaceAll(s, `"`, `""`))
	}
	return result
}