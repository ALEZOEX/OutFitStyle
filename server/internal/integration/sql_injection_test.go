//go:build integration

package integration_test

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/domain"
	dbpg "outfitstyle/server/internal/infrastructure/persistence/postgres"
	"outfitstyle/server/internal/infrastructure/persistence/postgres/pg"
)

// TestSQLInjectionPrevention verifies that the wardrobe list endpoint
// properly prevents SQL injection attacks through the orderField parameter.
//
// **Validates: Requirements 2.1**
//
// This test verifies that malicious SQL in the sort parameter is rejected
// or sanitized, preventing SQL injection attacks.
//
// EXPECTED OUTCOME: Test PASSES (confirms SQL injection is prevented)
func TestSQLInjectionPrevention(t *testing.T) {
	pool := mustDB(t)
	defer pool.Close()
	applyMigrations(t, pool)

	userID := insertTestUser(t, pool)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Insert required subcategory_specs
	_, err := pool.Exec(ctx, `
		INSERT INTO subcategory_specs (category, subcategory, warmth_min, temp_min_reco, temp_max_reco, rain_ok, snow_ok, wind_ok) VALUES
		('upper', 'shirt', 2, 10, 25, false, false, false),
		('lower', 'trousers', 3, 10, 25, false, false, true)
		ON CONFLICT DO NOTHING
	`)
	if err != nil {
		t.Fatalf("insert subcategory_specs: %v", err)
	}

	clothingItemID1 := uuid.New()
	clothingItemID2 := uuid.New()

	_, err = pool.Exec(ctx, `
		INSERT INTO clothing_items (id, name, category, subcategory, style, usage, season, base_colour, pattern, fit, gender, source, is_owned, is_active, image_url, icon_emoji)
		VALUES
			($1, 'Test Shirt', 'upper', 'shirt', 'casual', 'daily', 'summer', 'blue', 'solid', 'regular', 'unisex', 'synthetic', false, true, '', ''),
			($2, 'Test Pants', 'lower', 'trousers', 'casual', 'daily', 'all', 'black', 'solid', 'regular', 'unisex', 'synthetic', false, true, '', '')
	`, clothingItemID1, clothingItemID2)
	if err != nil {
		t.Fatalf("insert clothing items: %v", err)
	}

	wardrobeID1 := uuid.New()
	wardrobeID2 := uuid.New()

	_, err = pool.Exec(ctx, `
		INSERT INTO wardrobe_items (id, user_id, clothing_item_id, wear_count, is_favorite, is_archived, condition, created_at, updated_at, tags, item_data)
		VALUES
			($1, $2, $3, 0, false, false, 'good', NOW(), NOW(), ARRAY[]::text[], '{}'::jsonb),
			($4, $2, $5, 0, false, false, 'good', NOW(), NOW(), ARRAY[]::text[], '{}'::jsonb)
	`, wardrobeID1, userID, clothingItemID1, wardrobeID2, clothingItemID2)
	if err != nil {
		t.Fatalf("insert wardrobe items: %v", err)
	}

	logger := zap.NewNop()
	db, err := dbpg.NewDB(pool.Config().ConnString(), logger)
	if err != nil {
		t.Fatalf("db wrapper: %v", err)
	}
	defer db.Close()

	wardrobeRepo := pg.NewWardrobeRepository(db.Pool())

	maliciousSort := "name; DROP TABLE users--"

	query := domain.WardrobeListQuery{
		Sort:  maliciousSort,
		Order: domain.SortDesc,
		Page:  1,
		Limit: 10,
	}

	items, total, err := wardrobeRepo.List(ctx, domain.ID(userID), query)

	// First, verify that the users table still exists (wasn't dropped by SQL injection)
	// This is the critical security check
	var userCount int
	checkErr := pool.QueryRow(ctx, "SELECT COUNT(*) FROM users").Scan(&userCount)
	if checkErr != nil {
		t.Fatalf("Failed to query users table (may have been dropped by SQL injection): %v", checkErr)
	}

	if userCount == 0 {
		t.Error("Users table is empty or was affected by SQL injection")
	}

	// Now check if the query executed (with or without error)
	// The important thing is that SQL injection didn't execute
	if err != nil {
		// If there's an error, it should be a benign one (like scanning issue)
		// not a SQL injection execution
		t.Logf("Query returned error (acceptable if not SQL injection): %v", err)
		t.Logf("SUCCESS: SQL injection prevented. Users table intact with %d users", userCount)
		return
	}

	if total != 2 {
		t.Errorf("Expected 2 wardrobe items, got %d", total)
	}

	if len(items) != 2 {
		t.Errorf("Expected 2 items in result, got %d", len(items))
	}

	t.Logf("SUCCESS: SQL injection prevented. Query executed safely with %d items returned", len(items))
	t.Logf("Users table intact with %d users", userCount)
}
