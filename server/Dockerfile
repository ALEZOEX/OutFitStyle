# syntax=docker/dockerfile:1

FROM golang:1.24-alpine AS build
WORKDIR /src

RUN apk add --no-cache git ca-certificates

COPY server/go.mod server/go.sum ./
RUN go mod download

COPY server/ ./server/
COPY server/migrations/ ./migrations/

# Build binaries
WORKDIR /src/server
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/server ./cmd/server
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/migrate ./cmd/migrate || true
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/worker ./cmd/worker || true

FROM alpine:3.20
WORKDIR /app
RUN apk add --no-cache ca-certificates

COPY --from=build /out/server /app/server
COPY --from=build /out/migrate /app/migrate

# migrations inside image (needed for /app/migrate)
COPY server/migrations /app/migrations

# worker is optional and may not build, so we don't copy it

ENV MIGRATIONS_DIR=/app/migrations
EXPOSE 8080

# default: run api (compose overrides for worker)
CMD ["/bin/sh", "-c", "/app/migrate && /app/server"]