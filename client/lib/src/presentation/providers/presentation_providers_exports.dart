// Базовые провайдеры
export '../../features/wardrobe/presentation/providers/wardrobe_provider.dart'
    show apiClientProvider;
export '../routing/router.dart'
    show
        authStorageProvider,
        authRepositoryProvider,
        userIdProvider,
        authStateProvider,
        adminAccessProvider,
        AuthState,
        AuthStateNotifier;
export 'weather_provider.dart';
export 'user_preferences_provider.dart';
export 'user_location_provider.dart';

// Экспорт провайдеров из фичей
export '../../features/wardrobe/presentation/providers/wardrobe_provider.dart';
export '../../features/recommendations/presentation/providers/recommendations_provider.dart';
