FROM golang:1.24-alpine AS builder

# Install dependencies
RUN apk add --no-cache git ca-certificates

# Set working directory
WORKDIR /app

# Copy go mod files
COPY server/go.mod server/go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY server/ .

# Build the migration tool
RUN CGO_ENABLED=0 GOOS=linux go build -o migrate ./cmd/migrate

# Build the main server
RUN CGO_ENABLED=0 GOOS=linux go build -o main ./cmd/server

# Final stage
FROM alpine:latest

# Install ca-certificates for HTTPS requests
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy binaries from builder stage
COPY --from=builder /app/migrate .
COPY --from=builder /app/main .

# Copy database schema and migrations
COPY server/migrations/ ./migrations/
COPY server/database/init_v2.sql ./database/

# Security: Create non-root user
RUN addgroup -g 65532 nonroot &&\
    adduser -D -u 65532 -G nonroot nonroot

# Change ownership to non-root user
RUN chown -R nonroot:nonroot /root/

USER nonroot

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://localhost:8080/health || exit 1

# Expose port
EXPOSE 8080

# Run migrations first, then start the main service
CMD ["sh", "-c", "./migrate && ./main"]