// Main Export File
// Domain layer exports - interfaces only
export 'domain/domain_exports.dart';

// Data layer exports - repository implementations only
// Note: Do not export domain interfaces here to avoid ambiguous exports
export 'data/repositories/auth_repository.dart';
export 'data/repositories/profile_repository.dart';
export 'data/repositories/wardrobe_repository.dart';
export 'data/repositories/recommendations_repository.dart';

// UI layer exports
export 'ui/ui_exports.dart';

// Features exports
export 'features/features_exports.dart';

// Core layer exports
export 'core/core_exports.dart';

// NOTE: To avoid ambiguous exports, we do NOT export:
// - domain/repositories/auth_repository.dart (interface)
// The data layer implementations should be used directly
