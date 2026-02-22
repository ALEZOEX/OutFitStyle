FROM golang:1.24-alpine AS builder

# Установить локаль
ENV LANG=ru_RU.UTF-8
ENV LC_ALL=ru_RU.UTF-8

# Установить зависимости
RUN apk add --no-cache git ca-certificates gcc musl-dev

WORKDIR /app

# Копировать go.mod и go.sum для кэширования зависимостей
COPY go.mod go.sum ./
RUN go mod download

# Копировать исходный код
COPY . ./

# Собрать бинарники
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server cmd/server/main.go
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o migrate cmd/migrate/main.go

# Второй этап - минимальный образ
FROM alpine:latest

# Установить локаль
ENV LANG=ru_RU.UTF-8
ENV LC_ALL=ru_RU.UTF-8

# Установить ca-certificates для HTTPS
RUN apk --no-cache add ca-certificates

WORKDIR /app/

# Копировать бинарники из builder
COPY --from=builder /app/server /app/server
COPY --from=builder /app/migrate /app/migrate

# Копировать файлы миграций
COPY --from=builder /app/migrations /app/migrations

# Создать непривилегированный пользователь
RUN addgroup -g 65532 nonroot && \
    adduser -D -u 65532 -G nonroot nonroot

USER nonroot

# Проверка здоровья
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/health || exit 1

EXPOSE 8080

# Запуск сервера
CMD ["/app/server"]