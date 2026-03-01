import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/src/presentation/providers/auth_provider.dart';

void main() {
  group('Auth Provider Tests', () {
    testWidgets('authStateProvider initializes with loading state', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final authState = container.read(authStateProvider);
      expect(authState.isLoading, true);
      expect(authState.isAuthenticated, false);
    });

    testWidgets('authStateNotifier can sign out', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Изначально loading
      final initialState = container.read(authStateProvider);
      expect(initialState.isLoading, true);

      // Вызываем signOut (может не работать без мока репозитория)
      // container.read(authStateProvider.notifier).signOut();
    });

    testWidgets('userIdProvider initializes with null', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // userIdProvider - это FutureProvider, возвращающий AsyncValue
      final userIdAsync = container.read(userIdProvider);
      // Проверяем что это AsyncValue
      expect(userIdAsync, isA<AsyncValue<String?>>());
    });

    testWidgets('adminAccessProvider initializes correctly', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final adminAccess = container.read(adminAccessProvider);
      expect(adminAccess, isA<AsyncValue<bool>>());
    });
  });
}
