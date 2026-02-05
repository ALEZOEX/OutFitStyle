import 'package:flutter/material.dart';

class OutfitStyleComponents {
  // Кнопки
  static ButtonStyle primaryButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
    );
  }

  static ButtonStyle secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      side: BorderSide(color: Colors.grey[300]!),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  static ButtonStyle iconButtonStyle() {
    return IconButton.styleFrom(
      backgroundColor: Colors.grey[100],
      foregroundColor: Colors.grey[800],
      padding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Карточки
  static CardTheme cardTheme() {
    return CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
    );
  }

  // Типографика
  static TextStyle headlineLarge(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ) ??
        const TextStyle(fontSize: 32, fontWeight: FontWeight.w900);
  }

  static TextStyle headlineMedium(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ) ??
        const TextStyle(fontSize: 24, fontWeight: FontWeight.w800);
  }

  static TextStyle titleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ) ??
        const TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
  }

  static TextStyle titleMedium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ) ??
        const TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
  }

  static TextStyle bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ) ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  }

  // Отступы (8pt grid)
  static EdgeInsets paddingSmall = const EdgeInsets.all(8);
  static EdgeInsets paddingMedium = const EdgeInsets.all(16);
  static EdgeInsets paddingLarge = const EdgeInsets.all(24);
  static EdgeInsets paddingXSmall = const EdgeInsets.symmetric(horizontal: 8);
  static EdgeInsets paddingXMedium = const EdgeInsets.symmetric(horizontal: 16);
  static EdgeInsets paddingXLarge = const EdgeInsets.symmetric(horizontal: 24);
  static EdgeInsets paddingYSmall = const EdgeInsets.symmetric(vertical: 8);
  static EdgeInsets paddingYMedium = const EdgeInsets.symmetric(vertical: 16);
  static EdgeInsets paddingYLarge = const EdgeInsets.symmetric(vertical: 24);

  // Радиусы
  static BorderRadius radiusSmall = BorderRadius.circular(8);
  static BorderRadius radiusMedium = BorderRadius.circular(12);
  static BorderRadius radiusLarge = BorderRadius.circular(16);
  static BorderRadius radiusXLarge = BorderRadius.circular(20);

  // Тени
  static List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}
