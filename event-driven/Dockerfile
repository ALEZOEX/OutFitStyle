# Dockerfile for event-driven components
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the event-driven components
RUN go build -o event-handler ./cmd/event_handler

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/

# Copy the binary from builder stage
COPY --from=builder /app/event-handler .

# Expose port for health checks
EXPOSE 8080

CMD ["./event-handler"]