.PHONY: import-catalog

# Импорт каталога из NDJSON файла
import-catalog:
	go run server/scripts/import_catalog/main.go -file $(FILE) -dsn $(DSN) -batch $(or $(BATCH),300)

# Пример использования:
# make import-catalog FILE=basic_catalog.ndjson DSN=postgres://user:password@localhost:5432/dbname