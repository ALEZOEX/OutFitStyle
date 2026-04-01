import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ══════════════════════════════════════════════════════════════
// Цвета — синхронизированы с Landing Page (#d946ef, #f43f5e)
// ══════════════════════════════════════════════════════════════
class AppColors {
  // Бренд — Landing: primary-500 #d946ef, accent-500 #f43f5e
  static const Color primary = Color(0xFFD946EF);
  static const Color primaryLight = Color(0xFFF0ABFC); // primary-300
  static const Color primaryDark = Color(0xFFA21CAF); // primary-700
  static const Color secondary = Color(0xFFF43F5E); // accent-500
  static const Color secondaryLight = Color(0xFFFDA4AF); // accent-300
  static const Color secondaryDark = Color(0xFFBE123C); // accent-700

  // Фон
  static const Color backgroundLight = Color(
    0xFFFAFAFA,
  ); // Landing bg-[#fafafa]
  static const Color backgroundDark = Color(
    0xFF090A0F,
  ); // Landing dark:bg-[#090a0f]
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1A1A2E); // Deep purple-tinted dark
  static const Color surfaceDarkElevated = Color(
    0xFF232340,
  ); // Cards in dark mode

  // Текст
  static const Color textPrimaryLight = Color(0xFF111827); // gray-900
  static const Color textSecondaryLight = Color(0xFF6B7280); // gray-500
  static const Color textPrimaryDark = Color(0xFFF3F4F6); // gray-100
  static const Color textSecondaryDark = Color(0xFF9CA3AF); // gray-400

  // Состояния
  static const Color success = Color(0xFF10B981); // emerald-500
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color error = Color(0xFFEF4444); // red-500
  static const Color info = Color(0xFF3B82F6); // blue-500

  // Нейтральные
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Deprecated aliases для обратной совместимости
  static Color get grey => grey400;
  static Color get lightGrey => grey200;
  static Color get darkGrey => grey600;
}

// ══════════════════════════════════════════════════════════════
// Градиенты — Landing style
// ══════════════════════════════════════════════════════════════
class AppGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFFA855F7), Color(0xFFD946EF)],
  );

  static const LinearGradient primaryReversed = LinearGradient(
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
    colors: [Color(0xFF7C3AED), Color(0xFFA855F7), Color(0xFFD946EF)],
  );

  static const LinearGradient heroButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7C3AED), // vivid purple
      Color(0xFFA855F7), // purple-500
      Color(0xFFD946EF), // fuchsia-500
    ],
  );

  static const LinearGradient subtleCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AD946EF), // primary @ 10%
      Color(0x1AF43F5E), // secondary @ 10%
    ],
  );

  static LinearGradient cardLight = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33D946EF), // primary @ 20%
      Color(0x1AF43F5E), // secondary @ 10%
    ],
  );

  static LinearGradient cardDark = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x40D946EF), // primary @ 25%
      Color(0x26F43F5E), // secondary @ 15%
    ],
  );

  static const LinearGradient ctaBanner = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryDark, AppColors.secondaryDark],
  );
}

// ══════════════════════════════════════════════════════════════
// Отступы — единая система
// ══════════════════════════════════════════════════════════════
class AppSpacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;
  static const double massive = 64.0;

  // Размеры элементов
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 64.0;
  static const double iconButtonSize = 48.0;
  static const double fabSize = 56.0;
}

// ══════════════════════════════════════════════════════════════
// Скругления — Landing: rounded-xl=12, rounded-2xl=16, rounded-3xl=24
// ══════════════════════════════════════════════════════════════
class AppRadius {
  static const double xs = 4.0; // rounded
  static const double sm = 8.0; // rounded-lg
  static const double md = 12.0; // rounded-xl — стандард для кнопок и input
  static const double lg = 16.0; // rounded-2xl — стандард для карточек
  static const double xl = 20.0; // крупные карточки
  static const double xxl = 24.0; // rounded-3xl — модалки, hero-карточки
  static const double pill = 999.0; // rounded-full — кнопки-пилюли

  static BorderRadius get radiusXs => BorderRadius.circular(xs);
  static BorderRadius get radiusSm => BorderRadius.circular(sm);
  static BorderRadius get radiusMd => BorderRadius.circular(md);
  static BorderRadius get radiusLg => BorderRadius.circular(lg);
  static BorderRadius get radiusXl => BorderRadius.circular(xl);
  static BorderRadius get radiusXxl => BorderRadius.circular(xxl);
  static BorderRadius get radiusPill => BorderRadius.circular(pill);

  static ShapeBorder get shapeMd =>
      RoundedRectangleBorder(borderRadius: radiusMd);
  static ShapeBorder get shapeLg =>
      RoundedRectangleBorder(borderRadius: radiusLg);
  static ShapeBorder get shapeXl =>
      RoundedRectangleBorder(borderRadius: radiusXl);
  static ShapeBorder get shapeXxl =>
      RoundedRectangleBorder(borderRadius: radiusXxl);
}

// ══════════════════════════════════════════════════════════════
// Типографика — Inter, headings w800 (extrabold как Landing)
// ══════════════════════════════════════════════════════════════
class AppTypography {
  static TextStyle _base(
    BuildContext context, {
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Headings — Landing uses font-extrabold (w800)
  static TextStyle displayLarge(BuildContext context) => _base(
    context,
    fontSize: 40.0,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static TextStyle headlineLarge(BuildContext context) => _base(
    context,
    fontSize: 32.0,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.3,
  );

  static TextStyle headlineMedium(BuildContext context) =>
      _base(context, fontSize: 24.0, fontWeight: FontWeight.w700, height: 1.3);

  static TextStyle headlineSmall(BuildContext context) =>
      _base(context, fontSize: 20.0, fontWeight: FontWeight.w700, height: 1.3);

  // Body
  static TextStyle bodyLarge(BuildContext context) =>
      _base(context, fontSize: 16.0, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle bodyMedium(BuildContext context) => _base(
    context,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );

  static TextStyle bodySmall(BuildContext context) => _base(
    context,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );

  // Labels
  static TextStyle labelLarge(BuildContext context) =>
      _base(context, fontSize: 14.0, fontWeight: FontWeight.w600);

  static TextStyle labelMedium(BuildContext context) =>
      _base(context, fontSize: 12.0, fontWeight: FontWeight.w600);

  static TextStyle labelSmall(BuildContext context) => _base(
    context,
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
}

// ══════════════════════════════════════════════════════════════
// Темы
// ══════════════════════════════════════════════════════════════
class AppThemes {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFF5D0FE), // primary-200
        onPrimaryContainer: Color(0xFF701A75), // primary-900
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFFECDD3), // accent-200
        onSecondaryContainer: Color(0xFF881337), // accent-900
        tertiary: AppColors.secondary,
        onTertiary: Colors.white,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        onSurfaceVariant: AppColors.textSecondaryLight,
        surfaceContainerHighest: AppColors.grey100,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.grey200,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0.5,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLg,
          side: BorderSide(color: AppColors.grey200, width: 0.5),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusPill),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.grey300),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusPill),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey50,
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: AppColors.grey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.grey100,
        selectedColor: const Color(0xFFF5D0FE), // primary-200
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryLight,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        side: BorderSide(color: AppColors.grey200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        backgroundColor: AppColors.grey900,
        contentTextStyle: GoogleFonts.inter(fontSize: 14, color: Colors.white),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        backgroundColor: AppColors.surfaceLight,
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
        backgroundColor: AppColors.surfaceLight,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.grey200,
        thickness: 0.5,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight, // Lighter purple in dark
        onPrimary: Color(0xFF1A1A2E),
        primaryContainer: Color(0xFF4C1D95), // Deep purple
        onPrimaryContainer: Color(0xFFF5D0FE),
        secondary: AppColors.secondaryLight,
        onSecondary: Color(0xFF1A1A2E),
        secondaryContainer: Color(0xFF881337),
        onSecondaryContainer: Color(0xFFFECDD3),
        tertiary: AppColors.secondaryLight,
        onTertiary: Color(0xFF1A1A2E),
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        onSurfaceVariant: AppColors.textSecondaryDark,
        surfaceContainerHighest: AppColors.surfaceDarkElevated,
        error: Color(0xFFF87171), // red-400 — softer in dark
        onError: Color(0xFF1A1A2E),
        outline: Color(0xFF374151), // gray-700
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDarkElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLg,
          side: BorderSide(
            color: const Color(0xFF374151).withValues(alpha: 0.5),
          ),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: const Color(0xFF1A1A2E),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusPill),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: const Color(0xFF1A1A2E),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: Color(0xFF374151)),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusPill),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDarkElevated,
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(
            color: AppColors.primaryLight,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: Color(0xFFF87171)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDarkElevated,
        selectedColor: const Color(0xFF4C1D95),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        side: const BorderSide(color: Color(0xFF374151)),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        backgroundColor: AppColors.grey800,
        contentTextStyle: GoogleFonts.inter(fontSize: 14, color: Colors.white),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        backgroundColor: AppColors.surfaceDark,
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
        backgroundColor: AppColors.surfaceDark,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF374151),
        thickness: 0.5,
        space: 1,
      ),
    );
  }
}
