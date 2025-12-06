# Stage 1: Build the Go application
FROM golang:1.24-alpine AS builder
WORKDIR /app
# Install build dependencies
RUN apk add --no-cache gcc musl-dev linux-headers ca-certificates git

# Copy Go module files
COPY go.mod go.sum ./
# Download dependencies with retry mechanism
RUN for i in $(seq 1 3); do \
        echo "Attempt $i to download modules"; \
        go mod download && break || \
        if [ $i -lt 3 ]; then sleep 5; else exit 1; fi; \
    done

# Tidy up modules to ensure all dependencies are properly resolved
RUN for i in $(seq 1 3); do \
        echo "Attempt $i to tidy modules"; \
        go mod tidy && break || \
        if [ $i -lt 3 ]; then sleep 5; else exit 1; fi; \
    done

# Copy the source code
COPY . .
# Build the binary
RUN CGO_ENABLED=1 GOOS=linux go build -ldflags="-w -s" -o server ./cmd/server

# Stage 2: Create minimal runtime image
FROM alpine:latest
# Install ca-certificates for HTTPS calls
RUN apk --no-cache add ca-certificates
# Create appuser
RUN adduser -D -s /bin/sh appuser
# Set working directory
WORKDIR /app
# Copy the binary from builder stage
COPY --from=builder /app/server .
# Change ownership to appuser
RUN chown -R appuser:appuser ./
# Switch to appuser
USER appuser
# Expose port
EXPOSE 8080
# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD wget --quiet --tries=1 --spider http://localhost:8080/health || exit 1
# Run the binary
ENTRYPOINT ["./server"]