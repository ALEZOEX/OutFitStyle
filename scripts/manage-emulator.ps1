# ============================================================
# Скрипт управления Android эмулятором для Flutter
# Использование: .\manage-emulator.ps1 -action [start|stop|list|install]
# ============================================================

param(
    [string]$action = "help",
    [string]$device = ""
)

# Цвета для вывода
$Green = [System.ConsoleColor]::Green
$Red = [System.ConsoleColor]::Red
$Yellow = [System.ConsoleColor]::Yellow
$Cyan = [System.ConsoleColor]::Cyan

function Write-Success {
    param([string]$message)
    Write-Host "✓ $message" -ForegroundColor $Green
}

function Write-Error {
    param([string]$message)
    Write-Host "✗ $message" -ForegroundColor $Red
}

function Write-Warning {
    param([string]$message)
    Write-Host "⚠ $message" -ForegroundColor $Yellow
}

function Write-Info {
    param([string]$message)
    Write-Host "ℹ $message" -ForegroundColor $Cyan
}

function Check-Prerequisites {
    Write-Info "Проверка необходимых инструментов..."

    # Проверяем Flutter
    try {
        $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
        Write-Success "Flutter найден: $flutterVersion"
    }
    catch {
        Write-Error "Flutter не найден. Установите Flutter с https://flutter.dev"
        exit 1
    }

    # Проверяем Android Studio
    if (Test-Path "C:\Program Files\Android\Android Studio\bin\studio64.exe") {
        Write-Success "Android Studio найдена"
    }
    else {
        Write-Error "Android Studio не найдена. Установите с https://developer.android.com/studio"
        exit 1
    }

    # Проверяем ADB
    try {
        $adbVersion = adb version 2>&1 | Select-Object -First 1
        Write-Success "ADB найден"
    }
    catch {
        Write-Error "ADB не найден. Переустановите Android Studio SDK tools"
        exit 1
    }
}

function List-Emulators {
    Write-Info "Доступные эмуляторы:"
    Write-Host ""
    flutter emulators
    Write-Host ""
}

function Start-Emulator {
    param([string]$name)

    if ([string]::IsNullOrEmpty($name)) {
        Write-Error "Укажите имя эмулятора: -device <name>"
        List-Emulators
        exit 1
    }

    Write-Info "Запуск эмулятора: $name"

    # Запускаем эмулятор
    flutter emulators --launch $name

    Write-Info "Ожидание подключения (это может занять 1-2 минуты)..."
    Start-Sleep -Seconds 10

    # Ждем пока эмулятор загрузится
    $maxAttempts = 30
    $attempt = 0

    while ($attempt -lt $maxAttempts) {
        $devices = adb devices | Select-Object -Skip 1 | Where-Object { $_ -match "device$" }
        if ($devices) {
            Write-Success "Эмулятор подключен!"
            Write-Host ""
            adb devices
            Write-Host ""
            return $true
        }

        $attempt++
        Write-Info "Попытка $attempt/$maxAttempts..."
        Start-Sleep -Seconds 3
    }

    Write-Error "Не удалось подключить эмулятор"
    exit 1
}

function Stop-Emulator {
    Write-Info "Остановка эмулятора..."
    adb emu kill
    Write-Success "Эмулятор остановлен"
}

function Install-Emulator {
    Write-Info "Запуск Device Manager для создания нового эмулятора..."
    Write-Warning "Вручную создайте эмулятор в Android Studio"
    Write-Info "Рекомендуемые параметры:"
    Write-Host "  - Устройство: Pixel 5 или Pixel 6"
    Write-Host "  - API: 34+ (Android 14+)"
    Write-Host "  - RAM: 2-4 GB"
    Write-Host "  - Storage: 2048 MB"

    & "C:\Program Files\Android\Android Studio\bin\studio64.exe" --path "$env:USERPROFILE" &
}

function Get-Devices {
    Write-Info "Доступные устройства:"
    Write-Host ""
    flutter devices
    Write-Host ""
}

function Run-Flutter {
    param([string]$device)

    Write-Info "Запуск Flutter приложения..."

    if ([string]::IsNullOrEmpty($device)) {
        # Без указания устройства - Flutter выберет автоматически
        Set-Location -Path "client"
        flutter run
    }
    else {
        # С указанием устройства
        Set-Location -Path "client"
        flutter run -d $device
    }
}

function Show-Logs {
    param([string]$device)

    Write-Info "Показ логов..."

    if ([string]::IsNullOrEmpty($device)) {
        flutter logs
    }
    else {
        flutter logs -d $device
    }
}

function Show-Help {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗"
    Write-Host "║      Управление Android эмулятором для Flutter             ║"
    Write-Host "╚════════════════════════════════════════════════════════════╝"
    Write-Host ""
    Write-Host "Использование:" -ForegroundColor $Cyan
    Write-Host "  .\manage-emulator.ps1 -action <command> [-device <name>]"
    Write-Host ""
    Write-Host "Команды:" -ForegroundColor $Cyan
    Write-Host ""
    Write-Host "  list                    Список всех эмуляторов"
    Write-Host "  start -device <name>    Запустить эмулятор"
    Write-Host "  stop                    Остановить эмулятор"
    Write-Host "  install                 Создать новый эмулятор (Device Manager)"
    Write-Host "  devices                 Список подключенных устройств"
    Write-Host "  run [-device <name>]    Запустить Flutter приложение"
    Write-Host "  logs [-device <name>]   Показать логи"
    Write-Host "  check                   Проверить инструменты"
    Write-Host "  help                    Эта справка"
    Write-Host ""
    Write-Host "Примеры:" -ForegroundColor $Cyan
    Write-Host ""
    Write-Host "  .\manage-emulator.ps1 -action list"
    Write-Host "  .\manage-emulator.ps1 -action start -device Pixel_5_API_34"
    Write-Host "  .\manage-emulator.ps1 -action run"
    Write-Host "  .\manage-emulator.ps1 -action logs"
    Write-Host ""
}

# Основная логика
switch ($action.ToLower()) {
    "list" {
        Check-Prerequisites
        List-Emulators
    }
    "start" {
        Check-Prerequisites
        Start-Emulator -name $device
    }
    "stop" {
        Stop-Emulator
    }
    "install" {
        Check-Prerequisites
        Install-Emulator
    }
    "devices" {
        Get-Devices
    }
    "run" {
        Run-Flutter -device $device
    }
    "logs" {
        Show-Logs -device $device
    }
    "check" {
        Check-Prerequisites
        Write-Success "Все инструменты установлены корректно!"
    }
    "help" {
        Show-Help
    }
    default {
        Write-Error "Неизвестная команда: $action"
        Show-Help
        exit 1
    }
}
