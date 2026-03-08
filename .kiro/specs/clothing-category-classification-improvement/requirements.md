# Requirements Document

## Introduction

Система категоризации одежды в рекомендательном сервисе использует простую эвристику для распределения вещей по категориям (outerwear, upper, lower, footwear, accessory). Текущая реализация в функции `mapCategory` содержит неполные списки subcategory, что приводит к неправильному распределению вещей и использованию fallback значения "upper" для неизвестных типов. Это критически влияет на качество данных для обучения ranker модели.

Данный spec описывает требования к улучшенной системе категоризации, включающей мониторинг, расширенный маппинг, ML классификацию и инструменты для ручной корректировки.

## Glossary

- **Catalog_Import_System**: Система импорта каталога одежды из NDJSON файлов в базу данных
- **Category**: Основная категория одежды (outerwear, upper, lower, footwear, accessory)
- **Subcategory**: Подкатегория одежды (jeans, jacket, sneakers и т.д.)
- **Category_Mapper**: Компонент, отвечающий за маппинг subcategory в category
- **Classification_Dashboard**: Веб-интерфейс для мониторинга распределения категорий
- **ML_Classifier**: Модель машинного обучения для автоматической категоризации
- **Manual_Correction_Tool**: Инструмент для ручной корректировки неправильно распределенных вещей
- **Validation_System**: Система валидации категоризации при импорте
- **Clothing_Item**: Запись о вещи в базе данных с полями category, subcategory и другими атрибутами

## Requirements

### Requirement 1: Category Distribution Monitoring

**User Story:** Как data scientist, я хочу видеть метрики распределения вещей по категориям, чтобы выявлять проблемы в категоризации до обучения модели.

#### Acceptance Criteria

1. THE Classification_Dashboard SHALL display the total count of Clothing_Items per Category
2. THE Classification_Dashboard SHALL display the percentage distribution of Clothing_Items across all Categories
3. THE Classification_Dashboard SHALL display the list of Subcategories mapped to each Category with item counts
4. THE Classification_Dashboard SHALL display the list of unmapped Subcategories that fallback to default Category
5. WHEN a user selects a Category, THE Classification_Dashboard SHALL display detailed breakdown by Subcategory
6. THE Classification_Dashboard SHALL display the timestamp of last Catalog_Import_System execution
7. THE Classification_Dashboard SHALL refresh metrics within 5 seconds after Catalog_Import_System completion

### Requirement 2: Enhanced Category Mapping

**User Story:** Как разработчик, я хочу расширенный маппинг subcategory в category, чтобы уменьшить количество неправильно распределенных вещей.

#### Acceptance Criteria

1. THE Category_Mapper SHALL maintain a comprehensive mapping table for all known Subcategories
2. THE Category_Mapper SHALL map "t-shirt", "shirt", "blouse", "sweater", "hoodie", "vest", "top" to "upper" Category
3. THE Category_Mapper SHALL map "jeans", "pants", "trousers", "shorts", "skirt", "leggings", "trackpants" to "lower" Category
4. THE Category_Mapper SHALL map "jacket", "coat", "parka", "raincoat", "puffer", "blazer", "windbreaker" to "outerwear" Category
5. THE Category_Mapper SHALL map "shoes", "sneakers", "boots", "sandals", "loafers", "oxford", "slippers", "heels" to "footwear" Category
6. THE Category_Mapper SHALL map "hat", "cap", "scarf", "gloves", "belt", "bag", "watch", "sunglasses", "jewelry" to "accessory" Category
7. WHEN a Subcategory is not found in the mapping table, THE Category_Mapper SHALL log a warning with the unknown Subcategory value
8. THE Category_Mapper SHALL store the mapping table in a configuration file separate from code

### Requirement 3: ML-Based Classification

**User Story:** Как data scientist, я хочу ML классификатор для автоматической категоризации неизвестных вещей, чтобы минимизировать ручную работу.

#### Acceptance Criteria

1. THE ML_Classifier SHALL accept Clothing_Item attributes (name, subcategory, materials, style) as input
2. THE ML_Classifier SHALL predict the Category with confidence score between 0 and 1
3. WHEN confidence score is above 0.8, THE ML_Classifier SHALL automatically assign the predicted Category
4. WHEN confidence score is between 0.5 and 0.8, THE ML_Classifier SHALL flag the Clothing_I
правильно распределенных вещей, чтобы исправлять ошибки категоризации.

#### Acceptance Criteria

1. THE Manual_Correction_Tool SHALL display a paginated list of Clothing_Items filtered by Category
2. THE Manual_Correction_Tool SHALL allow filtering Clothing_Items by Subcategory, source, and confidence score
3. WHEN a user selects a Clothing_Item, THE Manual_Correction_Tool SHALL display all item attributes
4. THE Manual_Correction_Tool SHALL allow changing the Category of a Clothing_Item to any valid Category value
5. WHEN a Category is changed, THE Manual_Correction_Tool SHALL record the change with timestamp and user identifier
6. THE Manual_Correction_Tool SHALL validate that the new Category is one of the allowed values
7. THE Manual_Correction_Tool SHALL support bulk category updates for multiple Clothing_Items
8. WHEN a bulk update is requested, THE Manual_Correction_Tool SHALL display a confirmation dialog with the count of affected items

### Requirement 5: Import Validation System

**User Story:** Как разработчик, я хочу валидацию при импорте с предупреждениями, чтобы выявлять проблемы категоризации в момент импорта.

#### Acceptance Criteria

1. WHEN Catalog_Import_System processes a batch, THE Validation_System SHALL check each Clothing_Item for unknown Subcategories
2. WHEN an unknown Subcategory is detected, THE Validation_System SHALL log a warning with the Subcategory value and item name
3. THE Validation_System SHALL count the number of items using fallback Category per import batch
4. WHEN fallback Category usage exceeds 10 percent of batch, THE Validation_System SHALL log an error-level message
5. THE Validation_System SHALL generate a validation report after each import with statistics on category distribution
6. THE Validation_System SHALL store validation reports in a designated directory with timestamp in filename
7. WHEN ML_Classifier is available, THE Validation_System SHALL use it for unknown Subcategories before applying fallback

### Requirement 6: Category Mapping Configuration

**User Story:** Как администратор системы, я хочу управлять маппингом категорий через конфигурационный файл, чтобы добавлять новые subcategory без изменения кода.

#### Acceptance Criteria

1. THE Category_Mapper SHALL load mapping rules from a JSON configuration file at startup
2. THE configuration file SHALL contain a mapping of Subcategory to Category for all known types
3. THE configuration file SHALL specify the default fallback Category
4. WHEN the configuration file is invalid, THE Category_Mapper SHALL log an error and use hardcoded defaults
5. THE Category_Mapper SHALL support hot-reload of configuration file without service restart
6. WHEN configuration is reloaded, THE Category_Mapper SHALL validate all mapping rules before applying
7. THE configuration file SHALL be version-controlled in the repository

### Requirement 7: Audit Trail for Category Changes

**User Story:** Как data scientist, я хочу историю изменений категорий, чтобы анализировать качество категоризации и обучать модель на исправленных данных.

#### Acceptance Criteria

1. THE Catalog_Import_System SHALL record the original Category assignment for each Clothing_Item
2. WHEN a Category is changed via Manual_Correction_Tool, THE Catalog_Import_System SHALL store the change in an audit table
3. THE audit table SHALL contain fields: item_id, old_category, new_category, changed_by, changed_at, reason
4. THE Manual_Correction_Tool SHALL allow users to provide an optional reason for category change
5. THE Classification_Dashboard SHALL display the count of manually corrected items per Category
6. THE Catalog_Import_System SHALL provide an API endpoint to export audit trail as CSV
7. FOR ALL Clothing_Items with manual corrections, THE ML_Classifier SHALL use corrected categories as training data

### Requirement 8: Performance Requirements

**User Story:** Как разработчик, я хочу чтобы система категоризации работала быстро, чтобы не замедлять импорт больших каталогов.

#### Acceptance Criteria

1. WHEN processing a batch of 1000 Clothing_Items, THE Category_Mapper SHALL complete mapping within 100 milliseconds
2. WHEN ML_Classifier is used, THE classification of a single Clothing_Item SHALL complete within 50 milliseconds
3. THE Classification_Dashboard SHALL load initial metrics page within 2 seconds
4. THE Manual_Correction_Tool SHALL update a single Clothing_Item category within 500 milliseconds
5. WHEN Validation_System generates a report, THE report generation SHALL complete within 1 second for batches up to 10000 items
