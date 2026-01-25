package main

import (
	"log"
	"net/http"

	"github.com/gorilla/mux"
	httpSwagger "github.com/swaggo/http-swagger"
	_ "outfitstyle/server/docs" // Import our generated docs
)

// @title OutfitStyle API
// @version 1.0
// @description API Server for OutfitStyle application
// @host localhost:8080
// @BasePath /api/v1
func main() {
	r := mux.NewRouter()

	// Swagger UI endpoint
	r.PathPrefix("/swagger/").Handler(httpSwagger.WrapHandler)

	// Simple test endpoint
	r.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	}).Methods(http.MethodGet)

	log.Println("Starting server on :8080")
	log.Fatal(http.ListenAndServe(":8080", r))
}