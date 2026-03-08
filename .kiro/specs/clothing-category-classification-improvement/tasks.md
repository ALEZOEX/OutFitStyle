# Implementation Plan: Clothing Category Classification Improvement

## Overview

This implementation plan addresses the critical data quality issues in the clothing category classification system. The approach prioritizes the Category Mapper and Enhanced Mapping (blocking issue for ML training), followed by Validation System, Dashboard/API, and finally ML components. Each task builds incrementally with validation checkpoints to ensure quality.

## Tasks

- [x] 1. Set up database schema and migrations
  - [x] 1.1 Create category_audit table migration
    - Create migration file `000021_category_audit.up.sql` and `.down.sql`
    - Add columns: id, item_id, old_category, new_category, changed_by, changed_at, reason, confidence
    - Add indexes on item_id, changed_at, changed_by
    - Add category value constraints
    - _Requirements: 7.2, 7.3_

  - [x] 1.2 Add classification tracking fields to clothing_items table
    - Create migration to add classification_confidence and classification_source columns
    - Add constraint for classification_source values ('mapping', 'ml_auto', 'ml_flagged', 'manual')
    - _Requirements: 3.2, 3.3, 3.4, 7.1_

  - [x] 1.3 Create import_metadata table migration
    - Add columns: id, filename, started_at, completed_at, total_items, successful_items, skipped_items, validation_report_path, status
    - Add index on completed_at
    - Add status constraint ('running', 'completed', 'failed')
    - _Requirements: 5.5, 5.6_

- [x] 2. Implement Category Mapper with configuration-driven mapping
  - [x] 2.1 Create category mapping configuration file
    - Create `server/config/category_mapping.json` with version, fallback, and mappings
    - Include all 40+ subcategory mappings from requirements 2.2-2.6
    - Use lowercase keys for case-insensitive matching
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.8, 6.1, 6.2, 6.3, 6.7_

  - [x] 2.2 Implement CategoryMapper interface and configuration loading
    - Create `server/internal/catalog/category_mapper.go`
    - Implement MapCategory method with case-insensitive lookup
    - Implement configuration file loading with JSON validation
    - Implement GetUnmappedSubcategories method
    - Handle invalid configuration with hardcoded defaults fallback
    - _Requirements: 2.1, 2.7, 6.1, 6.4_

  - [ ]* 2.3 Write property test for Category Mapper
    - **Property 16: Invalid Configuration Fallback**
    - **Validates: Requirements 6.4**

  - [x] 2.4 Implement configuration hot-reload functionality
    - Implement ReloadConfig method with validation
    - Reject invalid configurations and maintain previous valid config
    - Add file watcher or manual reload endpoint
    - _Requirements: 6.5, 6.6_

  - [ ]* 2.5 Write p
y
  - Ensure all tests pass, ask the user if questions arise.

- [x] 4. Implement Validation System
  - [x] 4.1 Create ValidationReport data model
    - Create `server/internal/catalog/models.go` with ValidationReport struct
    - Include fields: Timestamp, TotalItems, UnknownSubcats, FallbackCount, FallbackPercent, CategoryDist, MLClassified, MLHighConfidence, MLLowConfidence, Errors, Warnings
    - _Requirements: 5.3, 5.5_

  - [x] 4.2 Implement ImportValidator interface
    - Create `server/internal/catalog/validator.go`
    - Implement ValidateBatch method to detect unknown subcategories
    - Track fallback usage count and percentage
    - Generate category distribution statistics
    - _Requirements: 5.1, 5.2, 5.3_

  - [x] 4.3 Implement fallback threshold detection and alerting
    - Check if fallback usage exceeds 10%
    - Log error-level message when threshold exceeded
    - Add warning to validation report
    - _Requirements: 5.4_

  - [ ]* 4.4 Write property test for fallback threshold alert
    - **Property 13: Fallback Threshold Alert**
    - **Validates: Requirements 5.4**

  - [x] 4.5 Implement validation report generation and file storage
    - Implement GenerateReport method
    - Create report files in `server/validation_reports/` directory
    - Use filename format: `import_YYYYMMDD_HHMMSS.json`
    - Include category distribution statistics
    - _Requirements: 5.5, 5.6_

  - [ ]* 4.6 Write property tests for Validation System
    - **Property 11: Unknown Subcategory Detection in Validation**
    - **Property 12: Fallback Usage Tracking**
    - **Property 14: Validation Report Generation**
    - **Validates: Requirements 5.1, 5.2, 5.3, 5.5, 5.6**

  - [ ]* 4.7 Write unit tests for Validation System
    - Test report generation with known data
    - Test fallback threshold detection (exactly 10%, 11%, 9%)
    - Test unknown subcategory detection
    - Test report file creation and naming
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

- [x] 5. Integrate Validation System with import pipeline
  - [x] 5.1 Update import script to use Validation System
    - Modify import batch processing to call ValidateBatch
    - Generate validation report after each import
    - Store report path in import_metadata table
    - Log warnings for unknown subcategories
    - _Requirements: 5.1, 5.2, 5.5, 5.6_

  - [x] 5.2 Update import_metadata tracking
    - Record import start/completion timestamps
    - Track successful, skipped, and total item counts
    - Store validation report path
    - Update status field appropriately
    - _Requirements: 5.5, 5.6_

- [~] 6. Checkpoint - Verify Validation System integration
  - Ensure all tests pass, ask the user if questions arise.

- [x] 7. Implement Classification Dashboard API
  - [x] 7.1 Create dashboard metrics endpoint
    - Create `server/internal/api/handlers/classification_handler.go`
    - Implement GET /api/v1/classification/metrics endpoint
    - Query database for total items, category distribution, percentages
    - Query unmapped subcategories from validation reports
    - Include last import timestamp from import_metadata
    - Return MetricsResponse with all dashboard data
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.6_

  - [ ]* 7.2 Write property tests for dashboard metrics
    - **Property 1: Category Distribution Accuracy**
    - **Property 3: Unmapped Subcategory Detection**
    - **Validates: Requirements 1.1, 1.2, 1.4**

  - [x] 7.3 Implement category breakdown endpoint
    - Implement GET /api/v1/classification/category/{category}/breakdown endpoint
    - Query all items for specified category
    - Group by subcategory with counts
    - Return CategoryBreakdownResponse
    - _Requirements: 1.3, 1.5_

  - [ ]* 7.4 Write property test for category breakdown
    - **Property 2: Subcategory Grouping Correctness**
    - **Validates: Requirements 1.3, 1.5**

  - [x] 7.5 Implement audit trail export endpoint
    - Implement GET /api/v1/classification/audit/export endpoint
    - Support date range filtering (from/to query parameters)
    - Query category_audit table
    - Generate CSV file with audit data
    - Return CSV file as download
    - _Requirements: 7.6_

  - [ ]* 7.6 Write unit tests for dashboard API endpoints
    - Test metrics endpoint with known database state
    - Test category breakdown endpoint
    - Test audit export endpoint with date filtering
    - Test error responses (400, 404, 500)
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 7.6_

- [x] 8. Implement Manual Correction Tool API
  - [x] 8.1 Create clothing items list endpoint
    - Implement GET /api/v1/clothing-items endpoint in `server/internal/api/handlers/correction_handler.go`
    - Support filtering by category, subcategory, source, confidence score
    - Implement pagination (page, limit query parameters)
    - Return ListItemsResponse with items, total, page, total_pages
    - _Requirements: 4.1, 4.2_

  - [ ]* 8.2 Write property test for category filter
    - **Property 7: Category Filter Correctness**
    - **Validates: Requirements 4.1, 4.2**

  - [x] 8.3 Implement single item category update endpoint
    - Implement PATCH /api/v1/clothing-items/{id}/category endpoint
    - Validate new category value against allowed values
    - Update clothing_item category and classification_source to 'manual'
    - Create audit record with old/new category, timestamp, user, reason
    - Use database transaction for atomicity
    - _Requirements: 4.3, 4.4, 4.5, 4.6_

  - [ ]* 8.4 Write property tests for category update
    - **Property 8: Category Update Validation**
    - **Property 9: Audit Trail Creation on Update**
    - **Property 18: Original Category Recording**
    - **Validates: Requirements 4.5, 4.6, 7.1, 7.2, 7.3**

  - [x] 8.5 Implement bulk category update endpoint
    - Implement POST /api/v1/clothing-items/bulk-update endpoint
    - Accept array of item IDs and new category
    - Validate all item IDs exist before updating
    - Update all items and create audit records in single transaction
    - Rollback on any error (atomicity)
    - _Requirements: 4.7, 4.8_

  - [ ]* 8.6 Write property test for bulk update atomicity
    - **Property 10: Bulk Update Atomicity**
    - **Validates: Requirements 4.7**

  - [ ]* 8.7 Write unit tests for Manual Correction Tool API
    - Test list endpoint with filtering and pagination
    - Test single update endpoint
    - Test bulk update endpoint
    - Test validation errors (invalid category, non-existent item)
    - Test transaction rollback scenarios
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8_

- [~] 9. Checkpoint - Verify Dashboard and Correction Tool APIs
  - Ensure all tests pass, ask the user if questions arise.

- [~] 10. Implement ML Classifier Client (Go)
  - [ ] 10.1 Create ML Classifier Client interface and HTTP client
    - Create `server/internal/ml/classifier_client.go`
    - Implement ClassifyItem method with HTTP POST to ML service
    - Implement HealthCheck method
    - Set 50ms timeout for classification requests
    - Handle connection errors, timeouts, and invalid responses gracefully
    - _Requirements: 3.1, 3.2, 8.2_

  - [ ]* 10.2 Write property test for ML confidence score range
    - **Property 4: ML Confidence Score Range**
    - **Validates: Requirements 3.2**

  - [ ] 10.3 Implement confidence-based category assignment logic
    - Add logic to auto-assign category when confidence > 0.8 (classification_source = 'ml_auto')
    - Add logic to flag for review when confidence 0.5-0.8 (classification_source = 'ml_flagged')
    - Use fallback category when confidence < 0.5 or ML unavailable
    - _Requirements: 3.3, 3.4, 3.5_

  - [ ]* 10.4 Write property tests for confidence-based assignment
    - **Property 5: High Confidence Auto-Assignment**
    - **Property 6: Low Confidence Flagging**
    - **Validates: Requirements 3.3, 3.4**

  - [ ]* 10.5 Write unit tests for ML Classifier Client
    - Test successful classification with mock ML service
    - Test timeout handling (mock slow service)
    - Test service unavailability (connection refused)
    - Test malformed response handling
    - Test confidence score edge cases
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 8.2_

- [~] 11. Integrate ML Classifier with Category Mapper
  - [ ] 11.1 Implement MapCategoryWithML method
    - Add ML Classifier Client as dependency to Category Mapper
    - Implement MapCategoryWithML to call ML service for unknown subcategories
    - Fall back to default category if ML unavailable or low confidence
    - Store confidence score in clothing_item record
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

  - [ ]* 11.2 Write property test for ML fallback chain priority
    - **Property 15: ML Fallback Chain Priority**
    - **Validates: Requirements 5.7**

  - [ ] 11.3 Update import pipeline to use ML classification
    - Modify import script to call MapCategoryWithML for unknown subcategories
    - Update validation system to track ML classification statistics
    - Log ML classification results (high/low confidence counts)
    - _Requirements: 3.3, 3.4, 5.7_

  - [ ]* 11.4 Write integration tests for ML-enhanced import pipeline
    - Test import with ML service available
    - Test import with ML service unavailable
    - Test confidence-based assignment logic
    - Verify validation reports include ML statistics
    - _Requirements: 3.3, 3.4, 5.7_

- [~] 12. Checkpoint - Verify ML Classifier integration
  - Ensure all tests pass, ask the user if questions arise.

- [~] 13. Implement ML Classifier Service (Python)
  - [ ] 13.1 Set up Python ML service project structure
    - Create `ml-service/` directory with FastAPI application
    - Set up virtual environment and dependencies (fastapi, uvicorn, scikit-learn, pandas)
    - Create `ml-service/services/category_classifier.py`
    - Create `ml-service/api/routes.py` for HTTP endpoints
    - _Requirements: 3.1_

  - [ ] 13.2 Implement CategoryClassifier class
    - Implement classify method accepting ClassifyRequest
    - Use TF-IDF vectorization for name and subcategory text
    - Use one-hot encoding for materials and style
    - Implement LogisticRegression or similar lightweight model
    - Return category prediction with confidence score
    - _Requirements: 3.1, 3.2_

  - [ ] 13.3 Implement classification API endpoint
    - Create POST /api/v1/classify endpoint
    - Accept JSON with name, subcategory, materials, style
    - Return JSON with category and confidence
    - Add request validation and error handling
    - _Requirements: 3.1, 3.2_

  - [ ]* 13.4 Write unit tests for CategoryClassifier
    - Test classification with various input combinations
    - Test confidence score calculation
    - Test model prediction logic
    - _Requirements: 3.1, 3.2_

  - [ ]* 13.5 Write integration tests for classification API
    - Test API endpoint with valid requests
    - Test API endpoint with invalid requests
    - Test concurrent classification requests
    - _Requirements: 3.1, 3.2_

- [~] 14. Implement ML training functionality
  - [ ] 14.1 Implement training data export from audit trail
    - Query category_audit table for manually corrected items
    - Join with clothing_items to get full item attributes
    - Export as training dataset (CSV or JSON)
    - Filter for items with changed_by != 'import' and != 'ml_classifier'
    - _Requirements: 7.7_

  - [ ]* 14.2 Write property test for manual correction training data
    - **Property 19: Manual Correction Training Data**
    - **Validates: Requirements 7.7**

  - [ ] 14.3 Implement CategoryClassifier train method
    - Accept training data with item attributes and corrected categories
    - Train LogisticRegression model on training data
    - Save trained model to disk for persistence
    - Log training metrics (accuracy, precision, recall)
    - _Requirements: 7.7_

  - [ ] 14.4 Add model loading on ML service startup
    - Load trained model from disk if exists
    - Fall back to default model if no trained model available
    - Log model version and training date
    - _Requirements: 7.7_

  - [ ]* 14.5 Write unit tests for training functionality
    - Test training with sample corrected data
    - Test model serialization/deserialization
    - Test model loading on startup
    - _Requirements: 7.7_

- [~] 15. Add performance optimizations and benchmarks
  - [ ] 15.1 Optimize Category Mapper for batch processing
    - Implement batch mapping method to reduce overhead
    - Add caching for configuration lookups
    - Optimize case-insensitive string matching
    - _Requirements: 8.1_

  - [ ] 15.2 Optimize database queries for dashboard
    - Add database indexes for category and subcategory columns
    - Use aggregation queries for category distribution
    - Cache dashboard metrics with 5-second TTL
    - _Requirements: 8.3_

  - [ ] 15.3 Optimize ML Classifier Client connection pooling
    - Use HTTP connection pooling for ML service requests
    - Implement circuit breaker for ML service failures
    - Add request batching for multiple classifications
    - _Requirements: 8.2_

  - [ ]* 15.4 Write benchmark tests
    - Benchmark category mapping for 1000 items (target: <100ms)
    - Benchmark ML classification single item (target: <50ms)
    - Benchmark dashboard metrics query (target: <2s)
    - Benchmark single category update (target: <500ms)
    - Benchmark validation report generation for 10000 items (target: <1s)
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [~] 16. Final integration and end-to-end testing
  - [ ] 16.1 Create end-to-end import flow test
    - Test complete pipeline: NDJSON → mapping → ML → validation → database
    - Test with ML service available and unavailable
    - Test with various configuration files
    - Verify audit trail, validation reports, and dashboard metrics
    - _Requirements: All_

  - [ ]* 16.2 Write integration tests for dashboard
    - Test dashboard with real database state
    - Test metric refresh after import
    - Test concurrent access to metrics
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7_

  - [ ]* 16.3 Write integration tests for manual correction workflow
    - Test complete workflow: browse → filter → update → verify audit
    - Test bulk updates with transaction rollback scenarios
    - Test concurrent updates
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8_

- [~] 17. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties using Rapid library
- Unit tests validate specific examples and edge cases
- Priority order: Category Mapper → Validation System → Dashboard/API → ML Components
- The Category Mapper is the blocking issue for ML training and should be completed first
- All property tests should run minimum 100 iterations
- Performance benchmarks should fail if targets are not met
