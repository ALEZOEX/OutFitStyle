# Stage 1: Build the Go application
FROM golang:1.21-alpine AS builder
WORKDIR /app
# Install build dependencies
RUN apk add --no-cache gcc musl-dev linux-headers ca-certificates git
# Copy Go module files
COPY go.mod go.sum ./
# Download dependencies
RUN go mod download
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