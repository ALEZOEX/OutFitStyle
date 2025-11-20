package http

import (
	"context"
	"net/http"
	"time"

	"github.com/gorilla/mux"
	"go.uber.org/zap"
)

// Server represents the HTTP server
type Server struct {
	server *http.Server
	logger *zap.Logger
}

// NewServer creates a new HTTP server
func NewServer(addr string, router *mux.Router, logger *zap.Logger) *Server {
	// Create HTTP server
	srv := &http.Server{
		Addr:         addr,
		Handler:      router,
		ReadTimeout:  30 * time.Second,
		WriteTimeout: 30 * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	return &Server{
		server: srv,
		logger: logger,
	}
}

// Start starts the HTTP server
func (s *Server) Start() error {
	s.logger.Info("🚀 Starting server on " + s.server.Addr)

	// Start server
	if err := s.server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		return err
	}

	return nil
}

// Stop stops the HTTP server
func (s *Server) Stop(ctx context.Context) error {
	s.logger.Info("🔧 Stopping server...")
	return s.server.Shutdown(ctx)
}
