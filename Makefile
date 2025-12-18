SHELL := /bin/bash

.PHONY: help
help:
	@echo "Targets:"
	@echo "  compose-up         - docker compose dev up"
	@echo "  compose-down       - docker compose dev down"
	@echo "  migrate            - run Go migrator"
	@echo "  seed               - seed catalog/specs"
	@echo "  test               - go test"
	@echo "  test-integration   - go test -tags=integration"
	@echo ""

.PHONY: compose-up
compose-up:
	docker compose -f infrastructure/docker-compose.yml up --build

.PHONY: compose-down
compose-down:
	docker compose -f infrastructure/docker-compose.yml down -v

.PHONY: migrate
migrate:
	cd server && DATABASE_URL=$$DATABASE_URL MIGRATIONS_DIR=./migrations go run ./cmd/migrate

.PHONY: seed
seed:
	./scripts/seed.sh

.PHONY: test
test:
	cd server && go test ./...

.PHONY: test-integration
test-integration:
	cd server && go test -tags=integration ./...