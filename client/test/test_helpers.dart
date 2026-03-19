// Вспомогательные функции и утилиты для тестов
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Обёртка для тестирования виджетов с Riverpod
Widget createTestWidget({
  required Widget child,
  List<Override> overrides = const [],
  List<ProviderObserver> observers = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    observers: observers,
    child: MaterialApp(home: child),
  );
}

/// Обёртка для тестирования виджетов с темой
Widget createThemedTestWidget({
  required Widget child,
  ThemeData? theme,
  ThemeData? darkTheme,
}) {
  return MaterialApp(
    theme: theme ?? ThemeData.light(),
    darkTheme: darkTheme ?? ThemeData.dark(),
    home: child,
  );
}

/// Найти виджет по тексту с частичным совпадением
Finder findTextContaining(String text) {
  return find.textContaining(text);
}

/// Найти все виджеты с текстом
Iterable<Widget> findAllTextWidgets(WidgetTester tester, String text) {
  return tester.widgetList<Widget>(find.text(text));
}

/// Проверить что виджет существует
bool widgetExists(WidgetTester tester, Finder finder) {
  return tester.any(finder);
}

/// Проверить что виджет видим
bool widgetIsVisible(WidgetTester tester, Finder finder) {
  return tester.any(finder) && !tester.any(find.byType(Offstage));
}

/// Дождаться завершения всех анимаций
Future<void> pumpUntilSettled(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

/// Дождаться появления виджета
Future<bool> waitForWidget(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final endTime = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(endTime)) {
    if (tester.any(finder)) {
      return true;
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  return false;
}

/// Дождаться исчезновения виджета
Future<bool> waitForWidgetToDisappear(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final endTime = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(endTime)) {
    if (!tester.any(finder)) {
      return true;
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  return false;
}

/// Эмулировать свайп
Future<void> swipe(WidgetTester tester, Offset start, Offset end) async {
  final gesture = await tester.startGesture(start);
  await gesture.moveTo(end);
  await gesture.up();
}

/// Эмулировать свайп влево
Future<void> swipeLeft(WidgetTester tester, {double startY = 200}) async {
  final start = const Offset(0, 200);
  final end = const Offset(-300, 200);
  await swipe(tester, start, end);
}

/// Эмулировать свайп вправо
Future<void> swipeRight(WidgetTester tester, {double startY = 200}) async {
  final start = const Offset(300, 200);
  final end = const Offset(0, 200);
  await swipe(tester, start, end);
}

/// Эмулировать pull-to-refresh
Future<void> pullToRefresh(WidgetTester tester) async {
  await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
  await tester.pump();
  await tester.pumpAndSettle();
}

/// Получить все текстовые виджеты на экране
List<String> getAllTexts(WidgetTester tester) {
  final texts = <String>[];
  final finder = find.byType(Text);
  for (final widget in tester.widgetList<Text>(finder)) {
    if (widget.data != null) {
      texts.add(widget.data!);
    }
  }
  return texts;
}

/// Проверить наличие текста на экране
bool hasText(WidgetTester tester, String text) {
  return tester.any(find.text(text));
}

/// Проверить наличие иконки на экране
bool hasIcon(WidgetTester tester, IconData icon) {
  return tester.any(find.byIcon(icon));
}

/// Проверить наличие кнопки на экране
bool hasButton(WidgetTester tester, String text) {
  return tester.any(find.widgetWithText(ElevatedButton, text)) ||
      tester.any(find.widgetWithText(TextButton, text)) ||
      tester.any(find.widgetWithText(OutlinedButton, text));
}

/// Нажать на кнопку по тексту
Future<void> tapButton(WidgetTester tester, String text) async {
  final buttonFinder =
      find
              .widgetWithText(ElevatedButton, text)
              .hitTestable()
              .evaluate()
              .isNotEmpty
          ? find.widgetWithText(ElevatedButton, text).hitTestable()
          : find
              .widgetWithText(TextButton, text)
              .hitTestable()
              .evaluate()
              .isNotEmpty
          ? find.widgetWithText(TextButton, text).hitTestable()
          : find.widgetWithText(OutlinedButton, text).hitTestable();

  await tester.tap(buttonFinder);
  await tester.pump();
}

/// Нажать на иконку
Future<void> tapIcon(WidgetTester tester, IconData icon) async {
  await tester.tap(find.byIcon(icon).hitTestable());
  await tester.pump();
}

/// Ввести текст в поле
Future<void> enterText(WidgetTester tester, Finder finder, String text) async {
  await tester.enterText(finder, text);
  await tester.pump();
}

/// Ввести текст в поле по hint
Future<void> enterTextByHint(
  WidgetTester tester,
  String hint,
  String text,
) async {
  await tester.enterText(
    find.byWidgetPredicate((widget) {
      if (widget is TextField) {
        final decorator = (widget as dynamic).decorator;
        if (decorator != null && decorator.hintText == hint) {
          return true;
        }
      }
      if (widget is TextFormField) {
        final decorator = (widget as dynamic).decorator;
        if (decorator != null && decorator.hintText == hint) {
          return true;
        }
      }
      return false;
    }),
    text,
  );
  await tester.pump();
}

/// Создать тестовый контекст
BuildContext createTestContext(WidgetTester tester) {
  return tester.element(find.byType(MaterialApp).first);
}

/// Получить размер экрана
Size getScreenSize(WidgetTester tester) {
  return tester.binding.platformDispatcher.views.first.physicalSize;
}

/// Получить центр экрана
Offset getScreenCenter(WidgetTester tester) {
  final size = getScreenSize(tester);
  return Offset(size.width / 2, size.height / 2);
}

/// Матчер для проверки что Future завершается успешно
Matcher completesSuccessfully() => completes;

/// Матчер для проверки что Future выбрасывает исключение
Matcher throwsExceptionOfType<T>() => throwsA(isA<T>());

/// Асинхронный матчер для Future
Future<Matcher> asyncMatcher(Future<dynamic> future) async {
  try {
    await future;
    return completes;
  } catch (e) {
    return throwsA(anything);
  }
}

/// Логгер для тестов
class TestLogger {
  final List<String> _logs = [];

  void log(String message) {
    _logs.add('[${DateTime.now().toIso8601String()}] $message');
    debugPrint(message);
  }

  List<String> get logs => List.unmodifiable(_logs);

  void clear() {
    _logs.clear();
  }

  bool contains(String substring) {
    return _logs.any((log) => log.contains(substring));
  }
}

/// Создать логгер для тестов
TestLogger createTestLogger() => TestLogger();
