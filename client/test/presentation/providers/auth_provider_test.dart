import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:outfitstyle_client/src/presentation/providers/auth_provider.dart';

void main() {
  group('Auth Provider Tests', () {
    testWidgets('authStateProvider initializes with false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: SizedBox(),
        ),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final authState = container.read(authStateProvider);
      expect(authState, false);
    });

    testWidgets('authStateProvider can be updated', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Изначально false
      expect(container.read(authStateProvider), false);

      // Обновляем на true
      container.read(authStateProvider.notifier).state = true;
      expect(container.read(authStateProvider), true);

      // Обновляем обратно на false
      container.read(authStateProvider.notifier).state = false;
      expect(container.read(authStateProvider), false);
    });

    testWidgets('userIdProvider initializes with null', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final userId = container.read(userIdProvider);
      expect(userId, null);
    });

    testWidgets('userIdProvider can be updated', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const testUserId = 'test-user-123';

      // Изначально null
      expect(container.read(userIdProvider), null);

      // Устанавливаем ID
      container.read(userIdProvider.notifier).state = testUserId;
      expect(container.read(userIdProvider), testUserId);

      // Очищаем
      container.read(userIdProvider.notifier).state = null;
      expect(container.read(userIdProvider), null);
    });

    testWidgets('providers work together', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const testUserId = 'user-456';

      // Обновляем оба провайдера
      container.read(authStateProvider.notifier).state = true;
      container.read(userIdProvider.notifier).state = testUserId;

      // Проверяем состояние
      expect(container.read(authStateProvider), true);
      expect(container.read(userIdProvider), testUserId);
    });
  });
}
