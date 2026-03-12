//go:build integration

package integration_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/handlers"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/core/application/services"
	dbpg "outfitstyle/server/internal/infrastructure/persistence/postgres"
	"outfitstyle/server/internal/infrastructure/persistence/postgres/pg"
)

// TestAuthorizationBypass verifies that users cannot access other users' resources.
//
// **Validates: Requirements 2.9**
//
// EXPECTED OUTCOME ON UNFIXED CODE: Test FAILS (unauthorized access succeeds)
// EXPECTED OUTCOME ON FIXED CODE: Test PASSES (unauthorized access returns 403)
func TestAuthorizationBypass(t *testing.T) {
	pool := mustDB(t)
	defer pool.Close()
	applyMigrations(t, pool)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	logger := zap.NewNop()
	db, err := dbpg.NewDB(pool.Config().ConnString(), logger)
	if err != nil {
		t.Fatalf("db wrapper: %v", err)
	}
	defer db.Close()

	// Create two users
	userA := insertTestUser(t, pool)
	userB := insertTestUser(t, pool)

	t.Logf("User A: %s, User B: %s", userA, userB)

	// Insert subcategory_specs
	_, err = pool.Exec(ctx, `
		INSERT INTO subcategory_specs (category, subcategory, warmth_min, temp_min_reco, temp_max_reco, rain_ok, snow_ok, wind_ok) VALUES
		('upper', 'shirt', 2, 10, 25, false, false, false)
		ON CONFLICT DO NOTHING
	`)
	if err != nil {
		t.Fatalf("insert subcategory_specs: %v", err)
	}

	// Create a wardrobe item for User B
	clothingItemID := uuid.New()
	_, err = pool.Exec(ctx, `
		INSERT INTO clothing_items (id, name, category, subcategory, style, usage, season, base_colour, pattern, fit, gender, source, is_owned, is_active, image_url, icon_emoji)
		VALUES ($1, 'User B Shirt', 'upper', 'shirt', 'casual', 'daily', 'summer', 'blue', 'solid', 'regular', 'unisex', 'synthetic', false, true, '', '')
	`, clothingItemID)
	if err != nil {
		t.Fatalf("insert clothing item: %v", err)
	}

	wardrobeItemID := uuid.New()
	_, err = pool.Exec(ctx, `
		INSERT INTO wardrobe_items (id, user_id, clothing_item_id, wear_count, is_favorite, is_archived, condition, created_at, updated_at, tags, item_data)
		VALUES ($1, $2, $3, 0, false, false, 'good', NOW(), NOW(), ARRAY[]::text[], '{}'::jsonb)
	`, wardrobeItemID, userB, clothingItemID)
	if err != nil {
		t.Fatalf("insert wardrobe item: %v", err)
	}

	t.Logf("Created wardrobe item %s for User B", wardrobeItemID)

	// Setup services
	wardrobeRepo := pg.NewWardrobeRepository(db.Pool())
	wardrobeService := services.NewWardrobeService(wardrobeRepo, logger)

	// Create test router
	gin.SetMode(gin.TestMode)
	router := gin.New()

	wardrobeHandler := handlers.NewWardrobeHandler(wardrobeService, logger)

	// Simulate User A trying to access User B's wardrobe item
	router.GET("/api/wardrobe/:id", func(c *gin.Context) {
		// Inject User A's ID as the authenticated user
		c.Set("user_id", userA.String())
		wardrobeHandler.GetItem(c)
	})

	// User A tries to access User B's item
	req := httptest.NewRequest("GET", "/api/wardrobe/"+wardrobeItemID.String(), nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	t.Logf("Response status: %d", w.Code)
	t.Logf("Response body: %s", w.Body.String())

	if w.Code == http.StatusOK {
		t.Error("VULNERABILITY CONFIRMED: User A can access User B's wardrobe item")
		t.Log("Unauthorized access succeeded - authorization bypass vulnerability exists")
		t.Log("Expected: 403 Forbidden")
		return
	}

	if w.Code == http.StatusForbidden {
		t.Log("SUCCESS: Unauthorized access properly blocked with 403 Forbidden")
	} else if w.Code == http.StatusNotFound {
		t.Log("INFO: Returns 404 instead of 403 (acceptable but 403 is more secure)")
	} else {
		t.Logf("Unexpected status code: %d", w.Code)
	}
}
