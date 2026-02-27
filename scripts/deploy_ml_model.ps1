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
    Write-Error-Log "Model not found: $ModelPath"
    exit 1
}

if (-not (Test-Path $ManifestPath)) {
    Write-Error-Log "Manifest not found: $ManifestPath"
    exit 1
}

Write-Log "Deploying ML model to server"
Write-Log "=============================="
Write-Log "Model: $ModelPath"
Write-Log "Manifest: $ManifestPath"
Write-Log "Server: ${ServerUser}@${ServerHost}:${ServerPath}"

# Копирование модели на сервер
Write-Log "Copying model to server..."

# Создание директории на сервере
try {
    ssh ${ServerUser}@${ServerHost} "mkdir -p ${ServerPath}"
    Write-Log "Remote directory created" "Green"
} catch {
    Write-Warn-Log "Could not create remote directory: $_"
}

try {
    $targetModel = "${ServerUser}@${ServerHost}:${ServerPath}/model.cbm"
    scp $ModelPath $targetModel
    Write-Log "Model copied successfully" "Green"
} catch {
    Write-Error-Log "Error copying model: $_"
    Write-Warn-Log "Make sure SCP is available and you have server access"
    exit 1
}

try {
    $targetManifest = "${ServerUser}@${ServerHost}:${ServerPath}/model.pkl"
    scp $ManifestPath $targetManifest
    Write-Log "Manifest copied successfully" "Green"
} catch {
    Write-Error-Log "Error copying manifest: $_"
    exit 1
}

# Перезапуск ML сервиса
Write-Log "Restarting ML service..."

try {
    $sshCommands = @"
cd /opt/outfitstyle
# Пробуем docker compose (новая версия) или docker-compose (старая)
if command -v docker-compose &> /dev/null; then
    docker-compose restart ml-service
    sleep 5
    docker-compose ps ml-service
elif command -v docker &> /dev/null; then
    docker compose restart ml-service
    sleep 5
    docker compose ps ml-service
else
    echo "Docker not found"
    exit 1
fi
"@

    ssh ${ServerUser}@${ServerHost} $sshCommands
    Write-Log "ML service restarted" "Green"
} catch {
    Write-Error-Log "Error restarting ML service: $_"
    Write-Warn-Log "Try manual: ssh root@outfitstyle.ru 'cd /opt/outfitstyle && docker compose restart ml-service'"
    exit 1
}

# Проверка здоровья ML сервиса
Write-Log "Checking ML service health..."

try {
    $healthResponse = ssh ${ServerUser}@${ServerHost} "curl -s http://localhost:8000/health"

    if ($healthResponse -like '*"model_loaded"*true*') {
        Write-Log "ML service is running, model loaded" "Green"
    } else {
        Write-Error-Log "ML service did not load the model"
        Write-Warn-Log "Check logs: ssh ${ServerUser}@${ServerHost} 'docker compose logs ml-service | tail -50'"
        exit 1
    }
} catch {
    Write-Error-Log "Error checking health: $_"
    exit 1
}

# Версия модели
Write-Log "Model information:"

try {
    $checkScript = @'
import pickle
with open('models/model.pkl', 'rb') as f:
    manifest = pickle.load(f)
print("Model kind:", manifest.get('model_kind', 'unknown'))
print("Version:", manifest.get('version', 'unknown'))
print("Features:", len(manifest.get('feature_columns', [])))
print("Metrics:", manifest.get('metrics', {}))
'@
    
    # Сохраняем скрипт во временный файл
    $tempScript = [System.IO.Path]::GetTempFileName() + ".py"
    $checkScript | Out-File -FilePath $tempScript -Encoding UTF8
    
    # Копируем на сервер и выполняем
    scp $tempScript "${ServerUser}@${ServerHost}:/tmp/check_model.py"
    $versionInfo = ssh ${ServerUser}@${ServerHost} "cd /opt/outfitstyle && python /tmp/check_model.py"
    Write-Log $versionInfo "Cyan"
    
    # Удаляем временный файл
    Remove-Item $tempScript -Force
    ssh ${ServerUser}@${ServerHost} "rm /tmp/check_model.py"
} catch {
    Write-Warn-Log "Could not get model info: $_"
}

Write-Log "=============================="
Write-Log "Deployment completed successfully!"
Write-Log "=============================="

Write-Log ""
Write-Log "Verification commands:"
Write-Log "  curl http://${ServerHost}:8000/health"
Write-Log "  curl http://${ServerHost}:8000/ready"
Write-Log ""
