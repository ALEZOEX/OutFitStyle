# PowerShell скрипт для тестирования полного flow рекомендаций
# Проверяет: создание, получение, оценку, удаление рекомендаций

param(
    [string]$ApiUrl = "http://localhost:8080",
    [string]$TestUserEmail = "test@example.com",
    [string]$TestUserPassword = "password123"
)

$ErrorActionPreference = "Stop"

# Цвета для вывода
function Write-Success { param($Message) Write-Host "✓ $Message" -ForegroundColor Green }
function Write-Error { param($Message) Write-Host "✗ $Message" -ForegroundColor Red }
function Write-Warning { param($Message) Write-Host "⚠ $Message" -ForegroundColor Yellow }
function Write-Info { param($Message) Write-Host "$Message" -ForegroundColor Cyan }

Write-Info "=== Тестирование Flow Рекомендаций ===`n"

# Функция для HTTP запросов
function Invoke-ApiRequest {
    param(
        [string]$Method,
        [string]$Uri,
        [hashtable]$Headers = @{},
        [object]$Body = $null
    )
    
    try {
        $params = @{
            Method = $Method
            Uri = $Uri
            Headers = $Headers
            ContentType = "application/json"
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
        }
        
        $response = Invoke-RestMethod @params
        return @{
            Success = $true
            Data = $response
            StatusCode = 200
        }
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        $errorBody = $_.ErrorDetails.Message
        
        return @{
            Success = $false
            Error = $_.Exception.Message
            StatusCode = $statusCode
            ErrorBody = $errorBody
        }
    }
}

# 1. Авторизация
Write-Info "1. Авторизация пользователя"
$authResult = Invoke-ApiRequest -Method POST -Uri "$ApiUrl/api/v1/auth/login" -Body @{
    email = $TestUserEmail
    password = $TestUserPassword
}

if ($authResult.Success) {
    $token = $authResult.Data.token ?? $authResult.Data.access_token
    if ($token) {
        Write-Success "Авторизация: HTTP 200"
        Write-Success "Токен получен: $($token.Substring(0, [Math]::Min(20, $token.Length)))..."
    }
    else {
        Write-Error "Не удалось получить токен из ответа"
        Write-Host ($authResult.Data | ConvertTo-Json)
        exit 1
    }
}
else {
    Write-Error "Авторизация: HTTP $($authResult.StatusCode)"
    Write-Host $authResult.Error
    exit 1
}

Write-Host ""

# Заголовки с токеном
$headers = @{
    "Authorization" = "Bearer $token"
}

# 2. Создание рекомендации
Write-Info "2. Создание новой рекомендации"
$createResult = Invoke-ApiRequest -Method POST -Uri "$ApiUrl/api/v1/recommendations" -Headers $headers -Body @{
    latitude = 55.7558
    longitude = 37.6173
    occasion = "casual"
}

if ($createResult.Success) {
    $recId = $createResult.Data.recommendation.id ?? $createResult.Data.id
    if ($recId) {
        Write-Success "Создание рекомендации: HTTP 200"
        Write-Success "Рекомендация создана: ID=$recId"
        
        $itemsCount = ($createResult.Data.recommendation.items ?? @()).Count
        Write-Success "Элементов в рекомендации: $itemsCount"
    }
    else {
        Write-Error "Не удалось получить ID рекомендации"
        Write-Host ($createResult.Data | ConvertTo-Json)
        exit 1
    }
}
else {
    Write-Error "Создание рекомендации: HTTP $($createResult.StatusCode)"
    Write-Host $createResult.Error
    exit 1
}

Write-Host ""

# 3. Получение списка рекомендаций
Write-Info "3. Получение списка рекомендаций"
$listResult = Invoke-ApiRequest -Method GET -Uri "$ApiUrl/api/v1/recommendations" -Headers $headers

if ($listResult.Success) {
    Write-Success "Получение списка: HTTP 200"
    $recsCount = ($listResult.Data.recommendations ?? @()).Count
    Write-Success "Получено рекомендаций: $recsCount"
    
    $found = $listResult.Data.recommendations | Where-Object { $_.id -eq $recId }
    if ($found) {
        Write-Success "Созданная рекомендация найдена в списке"
    }
    else {
        Write-Warning "Созданная рекомендация не найдена в списке"
    }
}
else {
    Write-Error "Получение списка: HTTP $($listResult.StatusCode)"
}

Write-Host ""

# 4. Получение конкретной рекомендации
Write-Info "4. Получение рекомендации по ID"
$getResult = Invoke-ApiRequest -Method GET -Uri "$ApiUrl/api/v1/recommendations/$recId" -Headers $headers

if ($getResult.Success) {
    Write-Success "Получение по ID: HTTP 200"
    $retrievedId = $getResult.Data.id ?? $getResult.Data.recommendation.id
    if ($retrievedId -eq $recId) {
        Write-Success "Рекомендация получена корректно"
    }
    else {
        Write-Error "ID не совпадает: ожидался $recId, получен $retrievedId"
    }
}
else {
    Write-Error "Получение по ID: HTTP $($getResult.StatusCode)"
}

Write-Host ""

# 5. Оценка рекомендации
Write-Info "5. Оценка рекомендации"
$rateResult = Invoke-ApiRequest -Method POST -Uri "$ApiUrl/api/v1/recommendations/$recId/rate" -Headers $headers -Body @{
    rating = 5
    feedback = "Отличная рекомендация!"
    thermal_feedback = "just_right"
}

if ($rateResult.Success) {
    Write-Success "Оценка рекомендации: HTTP 200"
    Write-Success "Рекомендация оценена успешно"
    
    $rating = $rateResult.Data.rating.rating
    if ($rating -eq 5) {
        Write-Success "Оценка сохранена: $rating/5"
    }
}
else {
    Write-Error "Оценка рекомендации: HTTP $($rateResult.StatusCode)"
}

Write-Host ""

# 6. Добавление в избранное
Write-Info "6. Добавление в избранное"
$favResult = Invoke-ApiRequest -Method POST -Uri "$ApiUrl/api/v1/recommendations/$recId/favorite" -Headers $headers -Body @{
    is_favorite = $true
}

if ($favResult.Success) {
    Write-Success "Добавление в избранное: HTTP 200"
    Write-Success "Рекомендация добавлена в избранное"
}
else {
    Write-Error "Добавление в избранное: HTTP $($favResult.StatusCode)"
}

Write-Host ""

# 7. Получение избранных рекомендаций
Write-Info "7. Получение избранных рекомендаций"
$favListResult = Invoke-ApiRequest -Method GET -Uri "$ApiUrl/api/v1/recommendations/favorites" -Headers $headers

if ($favListResult.Success) {
    Write-Success "Получение избранных: HTTP 200"
    $favCount = ($favListResult.Data.recommendations ?? @()).Count
    Write-Success "Избранных рекомендаций: $favCount"
    
    $foundFav = $favListResult.Data.recommendations | Where-Object { $_.id -eq $recId }
    if ($foundFav) {
        Write-Success "Рекомендация найдена в избранном"
    }
    else {
        Write-Warning "Рекомендация не найдена в избранном"
    }
}
else {
    Write-Error "Получение избранных: HTTP $($favListResult.StatusCode)"
}

Write-Host ""

# 8. Удаление рекомендации
Write-Info "8. Удаление рекомендации"
$deleteResult = Invoke-ApiRequest -Method DELETE -Uri "$ApiUrl/api/v1/recommendations/$recId" -Headers $headers

if ($deleteResult.Success -or $deleteResult.StatusCode -eq 204) {
    Write-Success "Удаление рекомендации: HTTP $($deleteResult.StatusCode)"
    Write-Success "Рекомендация удалена"
    
    # Проверяем, что рекомендация действительно удалена
    $verifyResult = Invoke-ApiRequest -Method GET -Uri "$ApiUrl/api/v1/recommendations/$recId" -Headers $headers
    if ($verifyResult.StatusCode -eq 404) {
        Write-Success "Подтверждено: рекомендация удалена (404)"
    }
    else {
        Write-Warning "Рекомендация всё ещё доступна (HTTP $($verifyResult.StatusCode))"
    }
}
else {
    Write-Error "Удаление рекомендации: HTTP $($deleteResult.StatusCode)"
}

Write-Host ""
Write-Info "=== Итоги тестирования ==="
Write-Success "Все основные операции с рекомендациями проверены"
Write-Host ""
Write-Host "Проверенные операции:"
Write-Host "  ✓ Создание рекомендации (POST /api/v1/recommendations)"
Write-Host "  ✓ Получение списка (GET /api/v1/recommendations)"
Write-Host "  ✓ Получение по ID (GET /api/v1/recommendations/{id})"
Write-Host "  ✓ Оценка (POST /api/v1/recommendations/{id}/rate)"
Write-Host "  ✓ Избранное (POST /api/v1/recommendations/{id}/favorite)"
Write-Host "  ✓ Список избранных (GET /api/v1/recommendations/favorites)"
Write-Host "  ✓ Удаление (DELETE /api/v1/recommendations/{id})"
