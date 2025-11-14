.PHONY: help server client db clean all

help:
	@echo "OutfitStyle - Команды для разработки"
	@echo ""
	@echo "  make server      - Запустить Go API (localhost:8080)"
	@echo "  make client      - Запустить Flutter"
	@echo "  make db          - Запустить PostgreSQL"
	@echo "  make all         - Запустить всё через Docker"
	@echo "  make clean       - Остановить и очистить Docker"

server:
	@echo "🚀 Запуск Go API..."
	cd server/api && go run main.go

client:
	@echo "📱 Запустить Flutter..."
	cd client && flutter run

db:
	@echo "🗄️ Запуск PostgreSQL..."
	docker-compose up -d postgres

all:
	@echo "🐳 Запуск всех сервисов..."
	docker-compose up --build

clean:
	@echo "🧹 Очистка..."
	docker-compose down -v