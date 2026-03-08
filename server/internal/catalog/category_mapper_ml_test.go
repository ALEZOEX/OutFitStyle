package catalog

import (
	"context"
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
	"testing"
)

// mockMLClient is a mock implementation of MLClassifierClient for testing
type mockMLClient struct {
	response *MLClassifyResponse
	err      error
}

func (m *mockMLClient) ClassifyItem(ctx context.Context, req *MLClassifyRequest) (*MLClassifyResponse, error) {
	if m.err != nil {
		return nil, m.err
	}
	return m.response, nil
}

func TestMapCategoryWithML_ConfigMappingFound(t *testing.T) {
	tmpDir := t.TempDir()
	configPath := filepath.Join(tmpDir, "category_mapping.json")

	config := CategoryMappingConfig{
		Version:  "1.0.0",
		Fallback: "upper",
		Mappings: map[string]string{
			"shirt": "upper",
		},
	}

	configData, _ := json.Marshal(config)
	os.WriteFile(configPath, configData, 0644)

	mlClient := &mockMLClient{
		response: &MLClassifyResponse{
			Category:   "lower",
			Confidence: 0.9,
		},
	}

	mapper, err := NewCategoryMapper(configPath, mlClient)
	if err != nil {
		t.Fatalf("Failed to create mapper: %v", err)
	}

	item := &ClothingItem{
		Name:        "Test Shirt",
		Subcategory: "shirt",
		Materials:   []string{"cotton"},
		Style:       "casual",
	}

	category, confidence, err := mapper.MapCategoryWithML(context.Background(), item)
	if err != nil {
		t.Fatalf("MapCategoryWithML() error = %v", err)
	}

	if category != "upper" {
		t.Errorf("Expected category 'upper' from config, got '%s'", category)
	}

	if confidence != 0 {
		t.Errorf("Expected confidence 0 for config mapping, got %f", confidence)
	}
}

func TestMapCategoryWithML_HighConfidenceMLClassification(t *testing.T) {
	tmpDir := t.TempDir()
	configPath := filepath.Join(tmpDir, "category_mapping.json")

	config := CategoryMappingConfig{
		Version:  "1.0.0",
		Fallback: "upper",
		Mappings: map[string]string{
			"shirt": "upper",
		},
	}

	configData, _ := json.Marshal(config)
	os.WriteFile(configPath, configData, 0644)

	mlClient := &mockMLClient{
		response: &MLClassifyResponse{
			Category:   "outerwear",
			Confidence: 0.95,
		},
	}

	mapper, err := NewCategoryMapper(configPath, mlClient)
	if err != nil {
		t.Fatalf("Failed to create mapper: %v", err)
	}

	item := &ClothingItem{
		Name:        "Puffer Vest",
		Subcategory: "puffer-vest",
		Materials:   []string{"polyester"},
		Style:       "sporty",
	}

	category, confidence, err := mapper.MapCategoryWithML(context.Background(), item)
	if err != nil {
		t.Fatalf("MapCategoryWithML() error = %v", err)
	}

	if category != "outerwear" {
		t.Errorf("Expected category 'outerwear' from ML, got '%s'", category)
	}

	if confidence != 0.95 {
		t.Errorf("Expected confidence 0.95, got %f", confidence)
	}
}

func TestMapCategoryWithML_MediumConfidenceMLClassification(t *testing.T) {
	tmpDir := t.TempDir()
	configPath := filepath.Join(tmpDir, "category_mapping.json")

	config := CategoryMappingConfig{
		Version:  "1.0.0",
		Fallback: "upper",
		Mappings: map[string]string{},
	}

	configData, _ := json.Marshal(config)
	os.WriteFile(configPath, configData, 0644)

	mlClient := &mockMLClient{
		response: &MLClassifyResponse{
			Category:   "footwear",
			Confidence: 0.65,
		},
	}

	mapper, err := NewCategoryMapper(configPath, mlClient)
	if err != nil {
		t.Fatalf("Failed to create mapper: %v", err)
	}

	item := &ClothingItem{
		Name:        "Unusual Shoes",
		Subcategory: "weird-shoes",
		Materials:   []string{"leather"},
		Style:       "casual",
	}

	category, confidence, err := mapper.MapCategoryWithML(context.Background(), item)
	if err != nil {
		t.Fatalf("MapCategoryWithML() error = %v", err)
	}

	if category != "footwear" {
		t.Errorf("Expected category 'footwear' from ML, got '%s'", category)
	}

	if confidence != 0.65 {
		t.Errorf("Expected confidence 0.65, got %f", confidence)
	}
}

func TestMapCategoryWithML_LowConfidenceFallback(t *testing.T) {
	tmpDir := t.TempDir()
	configPath := filepath.Join(tmpDir, "category_mapping.json")

	config := CategoryMappingConfig{
		Version:  "1.0.0",
		Fallback: "accessory",
		Mappings: map[string]string{},
	}

	configData, _ := json.Marshal(config)
	os.WriteFile(configPath, configData, 0644)

	mlClient := &mockMLClient{
		response: &MLClassifyResponse{
			Category:   "footwear",
			Confidence: 0.3,
		},
	}

	mapper, err := NewCategoryMapper(configPath, mlClient)
	if err != nil {
		t.Fatalf("Failed to create mapper: %v", err)
	}

	item := &ClothingItem{
		Name:        "Mystery Item",
		Subcategory: "unknown",
		Materials:   []string{"unknown"},
		Style:       "unknown",
	}

	category, confidence, err := mapper.MapCategoryWithML(context.Background(), item)
	if err != nil {
		t.Fatalf("MapCategoryWithML() error = %v", err)
	}

	if category != "accessory" {
		t.Errorf("Expected fallback category 'accessory', got '%s'", category)
	}

	if confidence != 0 {
		t.Errorf("Expected confidence 0 for fallback, got %f", confidence)
	}
}

func TestMapCategoryWithML_MLServiceUnavailable(t *testing.T) {
	tmpDir := t.TempDir()
	configPath := filepath.Join(tmpDir, "category_mapping.json")

	config := CategoryMappingConfig{
		Version:  "1.0.0",
		Fallback: "upper",
		Mappings: map[string]string{},
	}

	configData, _ := json.Marshal(config)
	os.WriteFile(configPath, configData, 0644)

	mlClient := &mockMLClient{
		err: errors.New("ML service unavailable: connection refused"),
	}

	mapper, err := NewCategoryMapper(configPath, mlClient)
	if err != nil {
		t.Fatalf("Failed to create mapper: %v", err)
	}

	item := &ClothingItem{
		Name:        "Test Item",
		Subcategory: "unknown",
		Materials:   []string{"cotton"},
		Style:       "casual",
	}

	category, confidence, err := mapper.MapCategoryWithML(context.Background(), item)
	if err != nil {
		t.Fatalf("MapCategoryWithML() error = %v", err)
	}

	if category != "upper" {
		t.Errorf("Expected fallback category 'upper', got '%s'", category)
	}

	if confidence != 0 {
		t.Errorf("Expected confidence 0 for fallback, got %f", confidence)
	}
}

func TestMapCategoryWithML_NoMLClient(t *testing.T) {
	tmpDir := t.TempDir()
	configPath := filepath.Join(tmpDir, "category_mapping.json")

	config := CategoryMappingConfig{
		Version:  "1.0.0",
		Fallback: "lower",
		Mappings: map[string]string{},
	}

	configData, _ := json.Marshal(config)
	os.WriteFile(configPath, configData, 0644)

	mapper, err := NewCategoryMapper(configPath, nil)
	if err != nil {
		t.Fatalf("Failed to create mapper: %v", err)
	}

	item := &ClothingItem{
		Name:        "Test Item",
		Subcategory: "unknown",
		Materials:   []string{"cotton"},
		Style:       "casual",
	}

	category, confidence, err := mapper.MapCategoryWithML(context.Background(), item)
	if err != nil {
		t.Fatalf("MapCategoryWithML() error = %v", err)
	}

	if category != "lower" {
		t.Errorf("Expected fallback category 'lower', got '%s'", category)
	}

	if confidence != 0 {
		t.Errorf("Expected confidence 0 for fallback, got %f", confidence)
	}
}
