package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"
)

// TestRecommendationRatingProtection tests that users can only rate their own recommendations
func TestRecommendationRatingProtection() {
	fmt.Println("Testing recommendation rating protection...")
	
	// Create a test rating request
	ratingReq := map[string]interface{}{
		"rating":   5,
		"feedback": "Great recommendation!",
	}
	
	jsonData, err := json.Marshal(ratingReq)
	if err != nil {
		fmt.Printf("❌ Error marshaling rating request: %v\n", err)
		return
	}
	
	// Test 1: Valid token with matching user ID
	fmt.Println("Test 1: Rating own recommendation with valid token")
	
	// This would typically require creating a recommendation first
	// Then calling: POST /api/v1/recommendations/{id}/rate with valid token
	// The backend should verify that recommendation belongs to user in JWT
	
	// Make request with valid token
	req, err := http.NewRequest("POST", "http://localhost:8080/api/v1/recommendations/1/rate", bytes.NewBuffer(jsonData))
	if err != nil {
		fmt.Printf("❌ Error creating request: %v\n", err)
		return
	}
	
	// Add valid JWT token (would need to obtain from login)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer VALID_TOKEN_HERE") // In real test, this would be obtained from login
	
	client := &http.Client{Timeout: 5 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Printf("❌ Error making request: %v\n", err)
		return
	}
	defer resp.Body.Close()
	
	body, _ := io.ReadAll(resp.Body)
	fmt.Printf("Status: %d, Response: %s\n", resp.StatusCode, string(body))
	
	// Test 2: Invalid token / non-matching user ID
	fmt.Println("\nTest 2: Attempting to rate another user's recommendation")
	
	// Make request with valid token but attempting to access another user's recommendation
	req2, err := http.NewRequest("POST", "http://localhost:8080/api/v1/recommendations/999999/rate", bytes.NewBuffer(jsonData))
	if err != nil {
		fmt.Printf("❌ Error creating request: %v\n", err)
		return
	}
	
	req2.Header.Set("Content-Type", "application/json")
	req2.Header.Set("Authorization", "Bearer VALID_TOKEN_FOR_USER_1") // Token for user 1
	
	resp2, err := client.Do(req2)
	if err != nil {
		fmt.Printf("❌ Error making request: %v\n", err)
		return
	}
	defer resp2.Body.Close()
	
	body2, _ := io.ReadAll(resp2.Body)
	fmt.Printf("Status: %d, Response: %s\n", resp2.StatusCode, string(body2))
	
	// Expected: 403 Forbidden or 404 Not Found if implementation properly checks ownership
	if resp2.StatusCode == 403 || resp2.StatusCode == 404 {
		fmt.Println("✅ Correctly prevented access to another user's recommendation")
	} else {
		fmt.Println("❌ Failed to protect recommendation access")
	}
	
	fmt.Println("Rating protection test completed.")
}

func main() {
	TestRecommendationRatingProtection()
}