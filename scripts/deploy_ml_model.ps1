# Деплой ML модели на production сервер
# Использование: .\deploy_ml_model.ps1

param(
    [string]$ModelPath = "ml-service\models\model.cbm",
    [string]$ManifestPath = "ml-service\models\model.pkl",
    [string]$ServerUser = "root",
    [string]$ServerHost = "outfitstyle.ru",
    [string]$ServerPath = "/opt/outfitstyle/ml-models"
)

$ErrorActionPreference = "Stop"

# Цвета для вывода
function Write-Log {
    param([string]$Message, [string]$Color = "Green")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Write-Error-Log {
    param([string]$Message)
    Write-Log $Message "Red"
}

function Write-Warn-Log {
    param([string]$Message)
    Write-Log $Message "Yellow"
}

# Проверка существования файлов
if (-not (Test-Path $ModelPath)) {
    Write-Error-Log "Модель не найдена: $ModelPath"
    exit 1
}

if (-not (Test-Path $ManifestPath)) {
    Write-Error-Log "Manifest не найден: $ManifestPath"
    exit 1
}

Write-Log "Деплой ML модели на сервер"
Write-Log "============================"
Write-Log "Модель: $ModelPath"
Write-Log "Manifest: $ManifestPath"
Write-Log "Сервер: $ServerUser@$ServerHost:$ServerPath"

# Копирование модели на сервер
Write-Log "Копирование модели на сервер..."

try {
    scp $ModelPath "${ServerUser}@${ServerHost}:${ServerPath}/model.cbm"
    Write-Log "✓ Модель скопирована" "Green"
} catch {
    Write-Error-Log "Ошибка копирования модели: $_"
    Write-Warn-Log "Убедитесь что SCP доступен и у вас есть доступ к серверу"
    exit 1
}

try {
    scp $ManifestPath "${ServerUser}@${ServerHost}:${ServerPath}/model.pkl"
    Write-Log "✓ Manifest скопирован" "Green"
} catch {
    Write-Error-Log "Ошибка копирования manifest: $_"
    exit 1
}

# Перезапуск ML сервиса
Write-Log "Перезапуск ML сервиса..."

try {
    ssh ${ServerUser}@${ServerHost} @"
cd /opt/outfitstyle
docker-compose restart ml-service
Start-Sleep -Seconds 5
docker-compose ps ml-service
"@
    Write-Log "✓ ML сервис перезапущен" "Green"
} catch {
    Write-Error-Log "Ошибка перезапуска ML сервиса: $_"
    exit 1
}

# Проверка здоровья ML сервиса
Write-Log "Проверка здоровья ML сервиса..."

try {
    $healthResponse = ssh ${ServerUser}@${ServerHost} "curl -s http://localhost:8000/health"
    
    if ($healthResponse -match '"model_loaded"\s*:\s*true') {
        Write-Log "✓ ML сервис работает, модель загружена" "Green"
    } else {
        Write-Error-Log "❌ ML сервис не загрузил модель"
        Write-Warn-Log "Проверьте логи: ssh ${ServerUser}@${ServerHost} 'docker-compose logs ml-service'"
        exit 1
    }
} catch {
    Write-Error-Log "Ошибка проверки здоровья: $_"
    exit 1
}

# Версия модели
Write-Log "Информация о модели:"

try {
    $versionInfo = ssh ${ServerUser}@${ServerHost} @"
cd /opt/outfitstyle
docker-compose exec -T ml-service python -c "
import pickle
with open('models/model.pkl', 'rb') as f:
    manifest = pickle.load(f)
print(f\"  Model kind: {manifest.get('model_kind', 'unknown')}\")
print(f\"  Version: {manifest.get('version', 'unknown')}\")
print(f\"  Features: {len(manifest.get('feature_columns', []))}\")
print(f\"  Metrics: {manifest.get('metrics', {})}\")
"
"@
    Write-Log $versionInfo "Cyan"
} catch {
    Write-Warn-Log "Не удалось получить информацию о модели: $_"
}

Write-Log "============================"
Write-Log "✅ Деплой завершён успешно!"
Write-Log "============================"

Write-Log ""
Write-Log "Проверка:"
Write-Log "  curl http://${ServerHost}:8000/health"
Write-Log "  curl http://${ServerHost}:8000/ready"
Write-Log ""
