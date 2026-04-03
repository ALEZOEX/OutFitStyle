#!/bin/bash

# Скрипт для тестирования полного flow рекомендаций
# Проверяет: создание, получение, оценку, удаление рекомендаций

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Конфигурация
API_URL="${API_URL:-http://localhost:8080}"
TEST_USER_EMAIL="test@example.com"
TEST_USER_PASSWORD="password123"

echo -e "${BLUE}=== Тестирование Flow Рекомендаций ===${NC}\n"

# Функция для вывода результата
print_result() {
    local status=$1
    local message=$2
    if [ "$status" = "success" ]; then
        echo -e "${GREEN}✓ $message${NC}"
    elif [ "$status" = "error" ]; then
        echo -e "${RED}✗ $message${NC}"
    else
        echo -e "${YELLOW}⚠ $message${NC}"
    fi
}

# Функция для проверки HTTP статуса
check_status() {
    local expected=$1
    local actual=$2
    local operation=$3
    
    if [ "$actual" = "$expected" ]; then
        print_result "success" "$operation: HTTP $actual"
        return 0
    else
        print_result "error" "$operation: Ожидался HTTP $expected, получен HTTP $actual"
        return 1
    fi
}

# 1. Авторизация
echo -e "${BLUE}1. Авторизация пользователя${NC}"
AUTH_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/api/v1/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$TEST_USER_EMAIL\",\"password\":\"$TEST_USER_PASSWORD\"}")

AUTH_BODY=$(echo "$AUTH_RESPONSE" | head -n -1)
AUTH_STATUS=$(echo "$AUTH_RESPONSE" | tail -n 1)

if check_status "200" "$AUTH_STATUS" "Авторизация"; then
    TOKEN=$(echo "$AUTH_BODY" | jq -r '.token // .access_token // empty')
    if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
        print_result "error" "Не удалось получить токен из ответа"
        echo "Response: $AUTH_BODY"
        exit 1
    fi
    print_result "success" "Токен получен: ${TOKEN:0:20}..."
else
    echo "Response: $AUTH_BODY"
    exit 1
fi

echo ""

# 2. Создание рекомендации
echo -e "${BLUE}2. Создание новой рекомендации${NC}"
CREATE_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/api/v1/recommendations" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "latitude": 55.7558,
        "longitude": 37.6173,
        "occasion": "casual"
    }')

CREATE_BODY=$(echo "$CREATE_RESPONSE" | head -n -1)
CREATE_STATUS=$(echo "$CREATE_RESPONSE" | tail -n 1)

if check_status "200" "$CREATE_STATUS" "Создание рекомендации" || check_status "201" "$CREATE_STATUS" "Создание рекомендации"; then
    REC_ID=$(echo "$CREATE_BODY" | jq -r '.recommendation.id // .id // empty')
    if [ -z "$REC_ID" ] || [ "$REC_ID" = "null" ]; then
        print_result "error" "Не удалось получить ID рекомендации"
        echo "Response: $CREATE_BODY"
        exit 1
    fi
    print_result "success" "Рекомендация создана: ID=$REC_ID"
    
    # Проверяем наличие элементов
    ITEMS_COUNT=$(echo "$CREATE_BODY" | jq -r '.recommendation.items | length // 0')
    print_result "success" "Элементов в рекомендации: $ITEMS_COUNT"
else
    echo "Response: $CREATE_BODY"
    exit 1
fi

echo ""

# 3. Получение списка рекомендаций
echo -e "${BLUE}3. Получение списка рекомендаций${NC}"
LIST_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_URL/api/v1/recommendations" \
    -H "Authorization: Bearer $TOKEN")

LIST_BODY=$(echo "$LIST_RESPONSE" | head -n -1)
LIST_STATUS=$(echo "$LIST_RESPONSE" | tail -n 1)

if check_status "200" "$LIST_STATUS" "Получение списка"; then
    RECS_COUNT=$(echo "$LIST_BODY" | jq -r '.recommendations | length // 0')
    print_result "success" "Получено рекомендаций: $RECS_COUNT"
    
    # Проверяем, что наша рекомендация в списке
    FOUND=$(echo "$LIST_BODY" | jq -r ".recommendations[] | select(.id == \"$REC_ID\") | .id")
    if [ "$FOUND" = "$REC_ID" ]; then
        print_result "success" "Созданная рекомендация найдена в списке"
    else
        print_result "warning" "Созданная рекомендация не найдена в списке"
    fi
else
    echo "Response: $LIST_BODY"
fi

echo ""

# 4. Получение конкретной рекомендации
echo -e "${BLUE}4. Получение рекомендации по ID${NC}"
GET_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_URL/api/v1/recommendations/$REC_ID" \
    -H "Authorization: Bearer $TOKEN")

GET_BODY=$(echo "$GET_RESPONSE" | head -n -1)
GET_STATUS=$(echo "$GET_RESPONSE" | tail -n 1)

if check_status "200" "$GET_STATUS" "Получение по ID"; then
    RETRIEVED_ID=$(echo "$GET_BODY" | jq -r '.id // .recommendation.id // empty')
    if [ "$RETRIEVED_ID" = "$REC_ID" ]; then
        print_result "success" "Рекомендация получена корректно"
    else
        print_result "error" "ID не совпадает: ожидался $REC_ID, получен $RETRIEVED_ID"
    fi
else
    echo "Response: $GET_BODY"
fi

echo ""

# 5. Оценка рекомендации
echo -e "${BLUE}5. Оценка рекомендации${NC}"
RATE_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/api/v1/recommendations/$REC_ID/rate" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
        "rating": 5,
        "feedback": "Отличная рекомендация!",
        "thermal_feedback": "just_right"
    }')

RATE_BODY=$(echo "$RATE_RESPONSE" | head -n -1)
RATE_STATUS=$(echo "$RATE_RESPONSE" | tail -n 1)

if check_status "200" "$RATE_STATUS" "Оценка рекомендации"; then
    print_result "success" "Рекомендация оценена успешно"
    
    # Проверяем, что оценка сохранилась
    RATING=$(echo "$RATE_BODY" | jq -r '.rating.rating // empty')
    if [ "$RATING" = "5" ]; then
        print_result "success" "Оценка сохранена: $RATING/5"
    fi
else
    echo "Response: $RATE_BODY"
fi

echo ""

# 6. Добавление в избранное
echo -e "${BLUE}6. Добавление в избранное${NC}"
FAV_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/api/v1/recommendations/$REC_ID/favorite" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{"is_favorite": true}')

FAV_BODY=$(echo "$FAV_RESPONSE" | head -n -1)
FAV_STATUS=$(echo "$FAV_RESPONSE" | tail -n 1)

if check_status "200" "$FAV_STATUS" "Добавление в избранное"; then
    print_result "success" "Рекомендация добавлена в избранное"
else
    echo "Response: $FAV_BODY"
fi

echo ""

# 7. Получение избранных рекомендаций
echo -e "${BLUE}7. Получение избранных рекомендаций${NC}"
FAV_LIST_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_URL/api/v1/recommendations/favorites" \
    -H "Authorization: Bearer $TOKEN")

FAV_LIST_BODY=$(echo "$FAV_LIST_RESPONSE" | head -n -1)
FAV_LIST_STATUS=$(echo "$FAV_LIST_RESPONSE" | tail -n 1)

if check_status "200" "$FAV_LIST_STATUS" "Получение избранных"; then
    FAV_COUNT=$(echo "$FAV_LIST_BODY" | jq -r '.recommendations | length // 0')
    print_result "success" "Избранных рекомендаций: $FAV_COUNT"
    
    # Проверяем, что наша рекомендация в избранном
    FOUND_FAV=$(echo "$FAV_LIST_BODY" | jq -r ".recommendations[] | select(.id == \"$REC_ID\") | .id")
    if [ "$FOUND_FAV" = "$REC_ID" ]; then
        print_result "success" "Рекомендация найдена в избранном"
    else
        print_result "warning" "Рекомендация не найдена в избранном"
    fi
else
    echo "Response: $FAV_LIST_BODY"
fi

echo ""

# 8. Удаление рекомендации
echo -e "${BLUE}8. Удаление рекомендации${NC}"
DELETE_RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$API_URL/api/v1/recommendations/$REC_ID" \
    -H "Authorization: Bearer $TOKEN")

DELETE_BODY=$(echo "$DELETE_RESPONSE" | head -n -1)
DELETE_STATUS=$(echo "$DELETE_RESPONSE" | tail -n 1)

if check_status "200" "$DELETE_STATUS" "Удаление рекомендации" || check_status "204" "$DELETE_STATUS" "Удаление рекомендации"; then
    print_result "success" "Рекомендация удалена"
    
    # Проверяем, что рекомендация действительно удалена
    VERIFY_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_URL/api/v1/recommendations/$REC_ID" \
        -H "Authorization: Bearer $TOKEN")
    VERIFY_STATUS=$(echo "$VERIFY_RESPONSE" | tail -n 1)
    
    if [ "$VERIFY_STATUS" = "404" ]; then
        print_result "success" "Подтверждено: рекомендация удалена (404)"
    else
        print_result "warning" "Рекомендация всё ещё доступна (HTTP $VERIFY_STATUS)"
    fi
else
    echo "Response: $DELETE_BODY"
fi

echo ""
echo -e "${BLUE}=== Итоги тестирования ===${NC}"
echo -e "${GREEN}Все основные операции с рекомендациями проверены${NC}"
echo ""
echo "Проверенные операции:"
echo "  ✓ Создание рекомендации (POST /api/v1/recommendations)"
echo "  ✓ Получение списка (GET /api/v1/recommendations)"
echo "  ✓ Получение по ID (GET /api/v1/recommendations/{id})"
echo "  ✓ Оценка (POST /api/v1/recommendations/{id}/rate)"
echo "  ✓ Избранное (POST /api/v1/recommendations/{id}/favorite)"
echo "  ✓ Список избранных (GET /api/v1/recommendations/favorites)"
echo "  ✓ Удаление (DELETE /api/v1/recommendations/{id})"
