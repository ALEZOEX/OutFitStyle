// Main Export File
// Domain layer exports - interfaces only
export 'domain/domain_exports.dart';

// Data layer exports - repository implementations only
// Примечание: Не экспортируем интерфейсы domain здесь, чтобы избежать неоднозначных экспортов
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

// ПРИМЕЧАНИЕ: Чтобы избежать неоднозначных экспортов, НЕ экспортируем:
// - domain/repositories/auth_repository.dart (interface)
// The data layer implementations should be used directly
