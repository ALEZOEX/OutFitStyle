# Flutter Service Worker Cache Fix Design

## Overview

Проблема заключается в том, что Flutter Service Worker агрессивно кеширует приложение и не обновляется при деплое новых версий. Пользователи продолжают видеть старую версию (build 04dcf98), которая несовместима с обновленным API и вызывает 401 ошибки. Решение должно обеспечить автоматическое обнаружение и применение обновлений Service Worker при сохранении offline функциональности PWA.

## Glossary

- **Bug_Condition (C)**: Условие, при котором Service Worker не обновляется после деплоя новой версии приложения
- **Property (P)**: Желаемое поведение - Service Worker должен обнаруживать изменения и обновлять кеш автоматически
- **Preservation**: Существующая offline функциональность PWA и кеширование неизменных ресурсов должны продолжать работать
- **flutter_service_worker.js**: Файл Service Worker, генерируемый Flutter build процессом, который управляет кешированием ресурсов
- **FLUTTER_SERVICE_WORKER_VERSION**: Хеш или версия, используемая для идентификации текущей версии Service Worker
- **Cache-Control headers**: HTTP заголовки, определяющие политику кеширования для Service Worker файла
- **skipWaiting()**: Метод Service Worker API, который заставляет новый Service Worker активироваться немедленно
- **clients.claim()**: Метод Service Worker API, который заставляет новый Service Worker взять контроль над всеми открытыми страницами

## Bug Details

### Bug Condition

Баг проявляется когда новая версия Flutter приложения деплоится на сервер, но браузер пользователя продолжает использовать старую версию из Service Worker cache. Service Worker не проверяет обновления или проверяет, но не применяет их корректно.

**Formal Specification:**
```
FUNCTION isBugCondition(deployment)
  INPUT: deployment of type DeploymentEvent
  OUTPUT: boolean

  RETURN deployment.newVersionDeployed = true
         AND serviceWorkerExists()
         AND NOT serviceWorkerUpdated(deployment.newVersion)
         AND clientStillUsesOldVersion()
END FUNCTION
```

### Examples

- **Пример 1**: Деплой новой версии на сервер → Пользователь открывает приложение → Видит старый build 04dcf98 → Получает 401 ошибки при API запросах
- **Пример 2**: Деплой новой версии → Пользователь перезагружает страницу (F5) → Service Worker отдает старую версию из кеша → Приложение не обновляется
- **Пример 3**: Деплой новой версии → Service Worker проверяет обновления → Находит новый flutter_service_worker.js → Но не активирует его из-за отсутствия skipWaiting()
- **Edge case**: Пользователь в offline режиме → Новая версия задеплоена → При возвращении online Service Worker должен обнаружить и применить обновление

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Offline доступ к приложению через закешированные ресурсы должен продолжать работать
- Быстрая загрузка приложения из кеша для актуальной версии должна сохраниться
- Первичная регистрация Service Worker и кеширование ресурсов для PWA должны работать как прежде
- Кеширование неизменных статических ресурсов (изображения, шрифты) должно продолжаться

**Scope:**
Все сценарии, которые НЕ связаны с обновлением версии приложения, должны остаться полностью неизменными. Это включает:
- Работу с приложением в offline режиме
- Загрузку приложения
iting() в Service Worker**: Даже если новый Service Worker обнаружен, он может ожидать закрытия всех вкладок перед активацией
   - Flutter генерирует Service Worker без автоматического skipWaiting()
   - Новый Service Worker находится в состоянии "waiting" неопределенно долго

3. **Отсутствие clients.claim()**: Новый Service Worker может активироваться, но не брать контроль над существующими клиентами
   - Пользователь должен закрыть все вкладки и открыть заново

4. **Проблемы с версионированием FLUTTER_SERVICE_WORKER_VERSION**: Service Worker может не корректно сравнивать версии или хеши
   - Хеш не изменяется между билдами
   - Логика сравнения версий работает некорректно

5. **Отсутствие механизма уведомления пользователя**: Даже если обновление обнаружено, пользователь не знает о необходимости перезагрузки

## Correctness Properties

Property 1: Bug Condition - Service Worker Auto-Update

_For any_ deployment event where a new version of the Flutter application is deployed to the server, the Service Worker SHALL detect the new version, download updated resources, activate the new Service Worker, and either automatically reload the application or notify the user to reload, ensuring the client uses the latest compatible version.

**Validates: Requirements 2.1, 2.2, 2.3, 2.4**

Property 2: Preservation - Offline and Caching Functionality

_For any_ scenario where no new version is deployed (application version is current), the Service Worker SHALL continue to provide offline access to cached resources, use cache for fast loading, register properly on first visit, and cache unchanged static resources for performance optimization.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4**

## Fix Implementation

### Changes Required

Предполагая, что наш анализ корректен:

**File 1**: `web/flutter_service_worker.js` (или шаблон, используемый Flutter для генерации)

**Changes**:
1. **Добавить skipWaiting()**: В событие 'install' добавить `self.skipWaiting()` для немедленной активации нового Service Worker

2. **Добавить clients.claim()**: В событие 'activate' добавить `self.clients.claim()` для немедленного контроля над клиентами

3. **Улучшить логику проверки версий**: Убедиться, что FLUTTER_SERVICE_WORKER_VERSION корректно обновляется при каждом билде

**File 2**: Server configuration (nginx.conf, .htaccess, или CDN settings)

**Changes**:
1. **Настроить Cache-Control для Service Worker**: Добавить заголовки для flutter_service_worker.js:
   ```
   Cache-Control: no-cache, no-store, must-revalidate
   Pragma: no-cache
   Expires: 0
   ```

2. **Настроить ETag или Last-Modified**: Обеспечить корректную валидацию кеша через условные запросы

**File 3**: `web/index.html` (или файл регистрации Service Worker)

**Changes**:
1. **Добавить логику обработки обновлений**: Слушать событие `controllerchange` и автоматически перезагружать страницу или показывать уведомление

2. **Добавить периодическую проверку обновлений**: Вызывать `registration.update()` через определенные интервалы

**File 4**: `lib/main.dart` (опционально, для Flutter-специфичной логики)

**Changes**:
1. **Добавить UI для уведомления об обновлениях**: Показывать snackbar или диалог когда доступно обновление

2. **Добавить кнопку "Обновить"**: Позволить пользователю вручную применить обновление

## Testing Strategy

### Validation Approach

Стратегия тестирования следует двухфазному подходу: сначала продемонстрировать баг на неисправленном коде, затем проверить, что исправление работает корректно и сохраняет существующее поведение.

### Exploratory Bug Condition Checking

**Goal**: Продемонстрировать баг ДО внесения исправлений. Подтвердить или опровергнуть анализ первопричины. Если опровергнем, потребуется пересмотр гипотезы.

**Test Plan**: Создать тестовое окружение с двумя версиями приложения. Задеплоить версию 1, открыть в браузере, затем задеплоить версию 2 и проверить, обновляется ли приложение. Запустить на НЕИСПРАВЛЕННОМ коде для наблюдения сбоев.

**Test Cases**:
1. **Deploy Update Test**: Задеплоить v1 → Открыть приложение → Задеплоить v2 → Перезагрузить страницу → Проверить, что все еще загружается v1 (будет сбой на неисправленном коде)
2. **Service Worker State Test**: Проверить состояние Service Worker через DevTools → Убедиться, что новый SW в состоянии "waiting" (будет сбой на неисправленном коде)
3. **Cache Headers Test**: Проверить HTTP заголовки для flutter_service_worker.js → Убедиться в отсутствии no-cache (будет сбой на неисправленном коде)
4. **Version Hash Test**: Сравнить FLUTTER_SERVICE_WORKER_VERSION между билдами → Проверить, изменяется ли хеш (может быть сбой на неисправленном коде)

**Expected Counterexamples**:
- Service Worker остается в состоянии "waiting" после деплоя новой версии
- flutter_service_worker.js кешируется браузером с длительным TTL
- Пользователь видит старую версию даже после hard refresh
- Возможные причины: отсутствие skipWaiting(), агрессивное кеширование, проблемы с версионированием

### Fix Checking

**Goal**: Проверить, что для всех входных данных, где выполняется условие бага, исправленная функция производит ожидаемое поведение.

**Pseudocode:**
```
FOR ALL deployment WHERE isBugCondition(deployment) DO
  result := serviceWorkerUpdate_fixed(deployment)
  ASSERT expectedBehavior(result)
  ASSERT result.clientUsesNewVersion = true
  ASSERT result.updateAppliedAutomatically = true OR result.userNotified = true
END FOR
```

### Preservation Checking

**Goal**: Проверить, что для всех входных данных, где условие бага НЕ выполняется, исправленная функция производит тот же результат, что и оригинальная.

**Pseudocode:**
```
FOR ALL scenario WHERE NOT isBugCondition(scenario) DO
  ASSERT serviceWorkerBehavior_original(scenario) = serviceWorkerBehavior_fixed(scenario)
END FOR
```

**Testing Approach**: Property-based тестирование рекомендуется для проверки сохранения поведения, потому что:
- Автоматически генерирует множество тестовых случаев по всему домену входных данных
- Выявляет граничные случаи, которые могут быть упущены в ручных unit тестах
- Предоставляет строгие гарантии, что поведение не изменилось для всех не-багованных входных данных

**Test Plan**: Сначала наблюдать поведение на НЕИСПРАВЛЕННОМ коде для offline режима и кеширования, затем написать property-based тесты, фиксирующие это поведение.

**Test Cases**:
1. **Offline Access Preservation**: Наблюдать, что offline доступ работает на неисправленном коде → Написать тест для проверки сохранения после исправления
2. **Cache Performance Preservation**: Наблюдать, что кеширование ускоряет загрузку на неисправленном коде → Написать тест для проверки сохранения производительности
3. **First Visit Registration Preservation**: Наблюдать, что первичная регистрация SW работает на неисправленном коде → Написать тест для проверки сохранения
4. **Static Resource Caching Preservation**: Наблюдать, что статические ресурсы кешируются на неисправленном коде → Написать тест для проверки сохранения

### Unit Tests

- Тест проверки Cache-Control заголовков для flutter_service_worker.js
- Тест наличия skipWaiting() в install событии
- Тест наличия clients.claim() в activate событии
- Тест изменения FLUTTER_SERVICE_WORKER_VERSION между билдами
- Тест обработки события controllerchange в клиентском коде

### Property-Based Tests

- Генерировать случайные сценарии деплоя и проверять, что Service Worker всегда обновляется
- Генерировать случайные offline сценарии и проверять, что кеш продолжает работать
- Тестировать различные комбинации состояний браузера (online/offline, первый визит/повторный) и проверять корректное поведение

### Integration Tests

- Полный flow: деплой v1 → открыть приложение → деплой v2 → проверить автоматическое обновление
- Тест offline режима после обновления Service Worker
- Тест уведомления пользователя об обновлении
- Тест ручного применения обновления через UI кнопку
- Тест работы приложения после обновления Service Worker (отсутствие 401 ошибок)
