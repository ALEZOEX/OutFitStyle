// Базовые провайдеры
export 'session_provider.dart'
    show
        sharedPreferencesProvider,
        sessionManagerProvider,
        authStateProvider;
export 'auth_provider.dart'
    show
        // Firebase провайдеры
        userIdProvider,
        adminAccessProvider;
export 'weather_provider.dart';
export 'user_preferences_provider.dart';
export 'user_location_provider.dart';

// Экспорт провайдеров из фичей
export '../../features/wardrobe/presentation/providers/wardrobe_provider.dart';
export '../../features/recommendations/presentation/providers/recommendations_provider.dart';
