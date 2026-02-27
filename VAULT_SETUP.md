# HashiCorp Vault — Production Secrets Management

## 🚀 Быстрый старт

### 1. Запуск Vault

```bash
# Production docker-compose
cd D:\outfitstyle
docker-compose -f docker-compose.prod.yml up -d vault

# Проверка
docker-compose ps vault
```

### 2. Инициализация

```bash
# Инициализация Vault и миграция секретов из .env
cd D:\outfitstyle
bash scripts/init_vault.sh
```

### 3. Проверка

```bash
# Получение секрета
vault kv get secret/outfitstyle/database

# Список секретов
vault kv list secret/outfitstyle
```

---

## 📁 Структура секретов

```
secret/outfitstyle/
├── database
│   ├── username: outfitstyle
│   ├── password: ***
│   ├── database: outfitstyle
│   ├── host: postgres
│   └── port: 5432
│
├── jwt
│   ├── secret: ***
│   ├── access_ttl: 1h
│   └── refresh_ttl: 90d
│
├── api-keys
│   ├── openweather: ***
│   ├── google_client_id: ***
│   └── google_client_secret: ***
│
└── ml-service
    └── api_key: ***
```

---

## 🔧 Интеграция с Go backend

### Установка зависимости

```bash
cd server
go get github.com/hashicorp/vault/api
```

### Пример получения секретов

```go
// server/config/vault.go
package config

import (
    "fmt"
    "log"
    "os"
    
    vault "github.com/hashicorp/vault/api"
)

type VaultConfig struct {
    Address string
    Token   string
}

type Secrets struct {
    Database DatabaseSecrets
    JWT      JWTSecrets
    APIKeys  APIKeysSecrets
}

type DatabaseSecrets struct {
    Username string
    Password string
    Database string
    Host     string
    Port     string
}

type JWTSecrets struct {
    Secret     string
    AccessTTL  string
    RefreshTTL string
}

type APIKeysSecrets struct {
    OpenWeather      string
    GoogleClientID   string
    GoogleClientSecret string
}

func LoadVaultSecrets() (*Secrets, error) {
    vaultAddr := os.Getenv("VAULT_ADDR")
    if vaultAddr == "" {
        vaultAddr = "http://vault:8200"
    }
    
    vaultToken := os.Getenv("VAULT_TOKEN")
    if vaultToken == "" {
        vaultToken = os.Getenv("VAULT_ROOT_TOKEN")
    }
    
    config := vault.DefaultConfig()
    config.Address = vaultAddr
    
    client, err := vault.NewClient(config)
    if err != nil {
        return nil, fmt.Errorf("vault client: %w", err)
    }
    
    client.SetToken(vaultToken)
    
    secrets := &Secrets{}
    
    // Database secrets
    dbSecret, err := client.Logical().Read("secret/data/outfitstyle/database")
    if err != nil {
        return nil, fmt.Errorf("read database: %w", err)
    }
    if dbSecret != nil && dbSecret.Data != nil {
        data := dbSecret.Data["data"].(map[string]interface{})
        secrets.Database.Username = data["username"].(string)
        secrets.Database.Password = data["password"].(string)
        secrets.Database.Database = data["database"].(string)
        secrets.Database.Host = data["host"].(string)
        secrets.Database.Port = data["port"].(string)
    }
    
    // JWT secrets
    jwtSecret, err := client.Logical().Read("secret/data/outfitstyle/jwt")
    if err != nil {
        return nil, fmt.Errorf("read jwt: %w", err)
    }
    if jwtSecret != nil && jwtSecret.Data != nil {
        data := jwtSecret.Data["data"].(map[string]interface{})
        secrets.JWT.Secret = data["secret"].(string)
        secrets.JWT.AccessTTL = data["access_ttl"].(string)
        secrets.JWT.RefreshTTL = data["refresh_ttl"].(string)
    }
    
    // API keys
    apiSecret, err := client.Logical().Read("secret/data/outfitstyle/api-keys")
    if err != nil {
        return nil, fmt.Errorf("read api-keys: %w", err)
    }
    if apiSecret != nil && apiSecret.Data != nil {
        data := apiSecret.Data["data"].(map[string]interface{})
        secrets.APIKeys.OpenWeather = data["openweather"].(string)
        secrets.APIKeys.GoogleClientID = data["google_client_id"].(string)
        secrets.APIKeys.GoogleClientSecret = data["google_client_secret"].(string)
    }
    
    log.Println("Vault secrets loaded successfully")
    return secrets, nil
}
```

### Использование в main.go

```go
// server/cmd/main.go
func main() {
    // Загрузка секретов из Vault
    secrets, err := config.LoadVaultSecrets()
    if err != nil {
        log.Printf("Vault not available, using env vars: %v", err)
        // Fallback to env vars for development
        secrets = config.LoadFromEnv()
    }
    
    // Инициализация базы данных
    dbURL := fmt.Sprintf(
        "postgresql://%s:%s@%s:5432/%s?sslmode=disable",
        secrets.Database.Username,
        secrets.Database.Password,
        secrets.Database.Host,
        secrets.Database.Database,
    )
    
    // Инициализация JWT
    jwtSecret := secrets.JWT.Secret
    
    // ... остальная инициализация
}
```

---

## 🔧 Интеграция с Python ML сервисом

### Установка зависимости

```bash
cd ml-service
pip install hvac
```

### Пример получения секретов

```python
# ml-service/config/vault.py
import os
import hvac

def get_vault_client():
    """Создание клиента Vault"""
    vault_addr = os.getenv("VAULT_ADDR", "http://vault:8200")
    vault_token = os.getenv("VAULT_TOKEN")
    
    client = hvac.Client(url=vault_addr, token=vault_token)
    
    if not client.is_authenticated():
        raise Exception("Vault authentication failed")
    
    return client

def get_database_credentials():
    """Получение учётных данных БД"""
    client = get_vault_client()
    
    response = client.secrets.kv.v2.read_secret_version(
        path='outfitstyle/database',
        mount_point='secret'
    )
    
    data = response['data']['data']
    return {
        'username': data['username'],
        'password': data['password'],
        'database': data['database'],
        'host': data['host'],
        'port': data['port']
    }

def get_jwt_secret():
    """Получение JWT секрета"""
    client = get_vault_client()
    
    response = client.secrets.kv.v2.read_secret_version(
        path='outfitstyle/jwt',
        mount_point='secret'
    )
    
    return response['data']['data']['secret']
```

### Использование в приложении

```python
# ml-service/api/main.py
from config.vault import get_database_credentials, get_jwt_secret

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    try:
        # Попытка загрузки из Vault
        db_creds = get_database_credentials()
        DATABASE_URL = f"postgresql://{db_creds['username']}:{db_creds['password']}@{db_creds['host']}:5432/{db_creds['database']}"
        logger.info("Secrets loaded from Vault")
    except Exception as e:
        # Fallback to env vars
        logger.warning(f"Vault unavailable, using env vars: {e}")
        DATABASE_URL = os.getenv("DATABASE_URL")
    
    yield
```

---

## 🔐 Vault Policy

### Политика для приложения

```hcl
# outfitstyle-app.hcl
path "secret/data/outfitstyle/database" {
  capabilities = ["read"]
}

path "secret/data/outfitstyle/jwt" {
  capabilities = ["read"]
}

path "secret/data/outfitstyle/api-keys" {
  capabilities = ["read"]
}

path "secret/data/outfitstyle/ml-service" {
  capabilities = ["read"]
}
```

### Применение политики

```bash
# Создание политики
vault policy write outfitstyle-app outfitstyle-app.hcl

# Создание токена для приложения
vault token create -policy=outfitstyle-app -ttl=720h

# Вывод: Token: s.xxxxxx
# Используйте этот токен в приложении
```

---

## 🔄 Автоматическая ротация секретов

### Database credentials (PostgreSQL)

```bash
# Включение database secrets engine
vault secrets enable database

# Настройка подключения к PostgreSQL
vault write database/config/postgresql \
    plugin_name=postgresql-database-plugin \
    allowed_roles="outfitstyle-role" \
    connection_url="postgresql://{{username}}:{{password}}@postgres:5432/outfitstyle?sslmode=disable" \
    username="vault-admin" \
    password="admin-password"

# Создание роли с автоматической ротацией
vault write database/roles/outfitstyle-role \
    db_name=postgresql \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"

# Получение временных учётных данных
vault read database/creds/outfitstyle-role

# Вывод:
# username: v-root-outfitstyle-role-xxxxx
# password: xxxxxxxx
# lease_duration: 1h
```

---

## 📊 Аудит

### Включение audit логов

```bash
# Включение audit логирования в файл
vault audit enable file file_path=/var/log/vault/audit.log

# Просмотр логов
tail -f /var/log/vault/audit.log
```

### Пример audit лога

```json
{
  "time": "2024-02-27T21:00:00.000Z",
  "type": "request",
  "auth": {
    "client_token": "s.xxxxxx",
    "policies": ["outfitstyle-app"]
  },
  "request": {
    "operation": "read",
    "path": "secret/data/outfitstyle/database"
  },
  "response": {
    "status": "success"
  }
}
```

---

## 🚨 Backup и восстановление

### Backup

```bash
# Остановка записи
vault operator seal

# Копирование данных
cp -r /vault/data /backup/vault-data

# Восстановление
vault operator unseal
```

### Disaster Recovery

```bash
# Snapshot
vault operator raft snapshot save backup.snap

# Восстановление
vault operator raft snapshot restore backup.snap
```

---

## 🎯 Production checklist

```
□ Vault запущен в production docker-compose
□ Секреты мигрированы из .env (init_vault.sh)
□ Создана политика outfitstyle-app
□ Приложения используют Vault API
□ Включён audit лог
□ Настроен backup (raft snapshot)
□ Мониторинг Vault (Prometheus + Grafana)
□ Документация для команды
```

---

## 📚 Ресурсы

- [Vault Documentation](https://developer.hashicorp.com/vault/docs)
- [Vault API](https://developer.hashicorp.com/vault/api-docs)
- [HVAC (Python client)](https://hvac.readthedocs.io/)
- [Vault Go client](https://pkg.go.dev/github.com/hashicorp/vault/api)
