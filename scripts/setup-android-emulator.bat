@echo off
REM ============================================================
REM  Скрипт автоматической настройки Android эмулятора
REM  для Flutter разработки на Windows
REM ============================================================

setlocal enabledelayedexpansion

echo.
echo ========================================
echo  Android Emulator Setup for Flutter
echo ========================================
echo.

REM Проверяем наличие необходимых инструментов
echo [1/5] Проверка наличия инструментов...

if exist "C:\Program Files\Android\Android Studio\bin\studio64.exe" (
    echo ✓ Android Studio найдена
    set ANDROID_STUDIO=C:\Program Files\Android\Android Studio
) else if exist "C:\Program Files (x86)\Android\android-studio\bin\studio.exe" (
    echo ✓ Android Studio найдена (x86)
    set ANDROID_STUDIO=C:\Program Files (x86)\Android\android-studio
) else (
    echo ✗ Android Studio не найдена!
    echo   Пожалуйста установите: https://developer.android.com/studio
    pause
    exit /b 1
)

REM Проверяем Flutter
if not exist "C:\flutter\bin\flutter.bat" (
    echo ✗ Flutter не найден в C:\flutter
    echo   Пожалуйста установите Flutter: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)
echo ✓ Flutter найден

REM Проверяем Java
java -version >nul 2>&1
if errorlevel 1 (
    echo ✗ Java не найдена!
    pause
    exit /b 1
)
echo ✓ Java найдена

echo.
echo [2/5] Получение списка доступных систем...

call "C:\flutter\bin\flutter.bat" emulators
echo.
echo Введите имя эмулятора из списка выше (например: Pixel_5_API_34)
set /p EMULATOR_NAME="Имя эмулятора: "

if "!EMULATOR_NAME!"=="" (
    echo ✗ Имя эмулятора не введено
    pause
    exit /b 1
)

echo.
echo [3/5] Проверка эмулятора...

REM Запускаем эмулятор
echo Запуск эмулятора: !EMULATOR_NAME!
start "" "!ANDROID_STUDIO!\bin\emulator.exe" -avd !EMULATOR_NAME!

REM Ждем запуска
echo Ожидание запуска эмулятора (это может занять 1-2 минуты)...
timeout /t 15 /nobreak

REM Проверяем подключение
echo.
echo [4/5] Проверка подключения ADB...

adb kill-server >nul 2>&1
timeout /t 2 /nobreak
adb start-server >nul 2>&1

REM Ждем пока эмулятор загрузится полностью
:wait_for_device
adb devices | find "device" >nul
if errorlevel 1 (
    echo Ожидание загрузки эмулятора...
    timeout /t 3 /nobreak
    goto wait_for_device
)

echo ✓ Эмулятор подключен!
echo.
adb devices
echo.

REM Показываем информацию
echo [5/5] Информация об эмуляторе:
adb shell getprop ro.build.version.release
adb shell getprop ro.product.model
echo.

REM Спрашиваем, запустить ли приложение
echo ========================================
echo ✓ Эмулятор успешно настроен и запущен!
echo ========================================
echo.
echo Доступные действия:
echo  1. flutter run          - Запустить приложение на эмуляторе
echo  2. flutter devices      - Список устройств
echo  3. adb logcat           - Логи эмулятора
echo  4. adb shell            - Консоль эмулятора
echo.

set /p RUN_APP="Запустить Flutter приложение? (y/n): "
if /i "!RUN_APP!"=="y" (
    echo.
    echo Перейдите в папку client:
    echo   cd client
    echo.
    echo Затем запустите:
    echo   flutter run
    echo.
)

pause
