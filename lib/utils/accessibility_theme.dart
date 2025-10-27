import 'package:flutter/material.dart';

/// Konfigurasi tema untuk accessibility features
/// Menyediakan high contrast themes dan scalable text configurations
class AccessibilityTheme {
  AccessibilityTheme._();

  /// Build high contrast light theme
  static ThemeData buildHighContrastLightTheme() {
    const primaryColor = Colors.black;
    const backgroundColor = Colors.white;
    const surfaceColor = Colors.white;
    const errorColor = Colors.red;
    const successColor = Colors.green;

    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: backgroundColor,
        secondary: primaryColor,
        onSecondary: backgroundColor,
        surface: surfaceColor,
        onSurface: primaryColor,
        background: backgroundColor,
        onBackground: primaryColor,
        error: errorColor,
        onError: backgroundColor,
      ),
      useMaterial3: true,

      // AppBar theme dengan high contrast
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 4,
        scrolledUnderElevation: 8,
        backgroundColor: primaryColor,
        foregroundColor: backgroundColor,
        iconTheme: IconThemeData(color: backgroundColor, size: 28),
        titleTextStyle: TextStyle(
          color: backgroundColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Text theme dengan ukuran yang lebih besar
      textTheme: _buildHighContrastTextTheme(),

      // Button themes dengan contrast tinggi
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: primaryColor, width: 2),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          minimumSize: const Size(88, 48),
          side: const BorderSide(color: primaryColor, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(88, 48),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      ),

      // FloatingActionButton dengan high contrast
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: backgroundColor,
        elevation: 8,
        highlightElevation: 12,
        iconSize: 28,
      ),

      // Card theme dengan border yang jelas
      cardTheme: CardThemeData(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: primaryColor, width: 2),
        ),
      ),

      // Input decoration dengan contrast tinggi
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 3),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: errorColor, width: 2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: errorColor, width: 3),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
        hintStyle: TextStyle(
          fontSize: 16,
          color: primaryColor.withValues(alpha: 0.7),
        ),
      ),

      // Chip theme dengan high contrast
      chipTheme: ChipThemeData(
        backgroundColor: backgroundColor,
        selectedColor: primaryColor,
        disabledColor: Colors.grey[300],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: backgroundColor,
        ),
        side: const BorderSide(color: primaryColor, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return backgroundColor;
        }),
        checkColor: WidgetStateProperty.all(backgroundColor),
        side: const BorderSide(color: primaryColor, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: primaryColor, size: 28),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: primaryColor,
        thickness: 2,
        space: 16,
      ),
    );
  }

  /// Build high contrast dark theme
  static ThemeData buildHighContrastDarkTheme() {
    const primaryColor = Colors.white;
    const backgroundColor = Colors.black;
    const surfaceColor = Colors.black;
    const errorColor = Colors.redAccent;
    const successColor = Colors.greenAccent;

    return ThemeData(
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        onPrimary: backgroundColor,
        secondary: primaryColor,
        onSecondary: backgroundColor,
        surface: surfaceColor,
        onSurface: primaryColor,
        background: backgroundColor,
        onBackground: primaryColor,
        error: errorColor,
        onError: backgroundColor,
      ),
      useMaterial3: true,

      // AppBar theme dengan high contrast
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 4,
        scrolledUnderElevation: 8,
        backgroundColor: backgroundColor,
        foregroundColor: primaryColor,
        iconTheme: IconThemeData(color: primaryColor, size: 28),
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Text theme dengan ukuran yang lebih besar
      textTheme: _buildHighContrastTextTheme(isDark: true),

      // Button themes dengan contrast tinggi
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: primaryColor, width: 2),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          minimumSize: const Size(88, 48),
          side: const BorderSide(color: primaryColor, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(88, 48),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      ),

      // FloatingActionButton dengan high contrast
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: backgroundColor,
        elevation: 8,
        highlightElevation: 12,
        iconSize: 28,
      ),

      // Card theme dengan border yang jelas
      cardTheme: CardThemeData(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: primaryColor, width: 2),
        ),
      ),

      // Input decoration dengan contrast tinggi
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 3),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: errorColor, width: 2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: errorColor, width: 3),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
        hintStyle: TextStyle(
          fontSize: 16,
          color: primaryColor.withValues(alpha: 0.7),
        ),
        fillColor: backgroundColor,
        filled: true,
      ),

      // Chip theme dengan high contrast
      chipTheme: ChipThemeData(
        backgroundColor: backgroundColor,
        selectedColor: primaryColor,
        disabledColor: Colors.grey[700],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: backgroundColor,
        ),
        side: const BorderSide(color: primaryColor, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return backgroundColor;
        }),
        checkColor: WidgetStateProperty.all(backgroundColor),
        side: const BorderSide(color: primaryColor, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: primaryColor, size: 28),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: primaryColor,
        thickness: 2,
        space: 16,
      ),
    );
  }

  /// Build text theme dengan ukuran yang lebih besar untuk accessibility
  static TextTheme _buildHighContrastTextTheme({bool isDark = false}) {
    final Color textColor = isDark ? Colors.white : Colors.black;

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 64,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 52,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 44,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
    );
  }

  /// Build theme dengan text scaling yang dapat disesuaikan
  static ThemeData buildScalableTextTheme({
    required ThemeData baseTheme,
    double textScaleFactor = 1.0,
  }) {
    return baseTheme.copyWith(
      textTheme: _scaleTextTheme(baseTheme.textTheme, textScaleFactor),
    );
  }

  /// Scale text theme berdasarkan factor
  static TextTheme _scaleTextTheme(TextTheme textTheme, double scaleFactor) {
    return TextTheme(
      displayLarge: textTheme.displayLarge?.copyWith(
        fontSize: (textTheme.displayLarge?.fontSize ?? 57) * scaleFactor,
      ),
      displayMedium: textTheme.displayMedium?.copyWith(
        fontSize: (textTheme.displayMedium?.fontSize ?? 45) * scaleFactor,
      ),
      displaySmall: textTheme.displaySmall?.copyWith(
        fontSize: (textTheme.displaySmall?.fontSize ?? 36) * scaleFactor,
      ),
      headlineLarge: textTheme.headlineLarge?.copyWith(
        fontSize: (textTheme.headlineLarge?.fontSize ?? 32) * scaleFactor,
      ),
      headlineMedium: textTheme.headlineMedium?.copyWith(
        fontSize: (textTheme.headlineMedium?.fontSize ?? 28) * scaleFactor,
      ),
      headlineSmall: textTheme.headlineSmall?.copyWith(
        fontSize: (textTheme.headlineSmall?.fontSize ?? 24) * scaleFactor,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        fontSize: (textTheme.titleLarge?.fontSize ?? 22) * scaleFactor,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        fontSize: (textTheme.titleMedium?.fontSize ?? 16) * scaleFactor,
      ),
      titleSmall: textTheme.titleSmall?.copyWith(
        fontSize: (textTheme.titleSmall?.fontSize ?? 14) * scaleFactor,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(
        fontSize: (textTheme.bodyLarge?.fontSize ?? 16) * scaleFactor,
      ),
      bodyMedium: textTheme.bodyMedium?.copyWith(
        fontSize: (textTheme.bodyMedium?.fontSize ?? 14) * scaleFactor,
      ),
      bodySmall: textTheme.bodySmall?.copyWith(
        fontSize: (textTheme.bodySmall?.fontSize ?? 12) * scaleFactor,
      ),
      labelLarge: textTheme.labelLarge?.copyWith(
        fontSize: (textTheme.labelLarge?.fontSize ?? 14) * scaleFactor,
      ),
      labelMedium: textTheme.labelMedium?.copyWith(
        fontSize: (textTheme.labelMedium?.fontSize ?? 12) * scaleFactor,
      ),
      labelSmall: textTheme.labelSmall?.copyWith(
        fontSize: (textTheme.labelSmall?.fontSize ?? 11) * scaleFactor,
      ),
    );
  }

  /// Predefined text scale factors
  static const double smallTextScale = 0.85;
  static const double normalTextScale = 1.0;
  static const double largeTextScale = 1.15;
  static const double extraLargeTextScale = 1.3;
  static const double accessibilityTextScale = 1.5;

  /// Get recommended text scale factor berdasarkan accessibility settings
  static double getRecommendedTextScale(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textScaleFactor = mediaQuery.textScaler.scale(1.0);

    // Jika user sudah mengatur text scale di system settings,
    // gunakan yang lebih besar antara system setting dan minimum accessibility scale
    if (textScaleFactor > normalTextScale) {
      return textScaleFactor;
    }

    // Default ke normal scale
    return normalTextScale;
  }

  /// Check apakah high contrast mode aktif
  static bool isHighContrastMode(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.highContrast;
  }

  /// Check apakah bold text mode aktif
  static bool isBoldTextMode(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.boldText;
  }

  /// Get theme berdasarkan accessibility preferences
  static ThemeData getAccessibilityAwareTheme({
    required BuildContext context,
    required ThemeData lightTheme,
    required ThemeData darkTheme,
    bool forceHighContrast = false,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final isDarkMode = mediaQuery.platformBrightness == Brightness.dark;
    final isHighContrast = forceHighContrast || mediaQuery.highContrast;
    final textScaleFactor = getRecommendedTextScale(context);

    ThemeData baseTheme;

    if (isHighContrast) {
      baseTheme = isDarkMode
          ? buildHighContrastDarkTheme()
          : buildHighContrastLightTheme();
    } else {
      baseTheme = isDarkMode ? darkTheme : lightTheme;
    }

    // Apply text scaling jika diperlukan
    if (textScaleFactor != normalTextScale) {
      baseTheme = buildScalableTextTheme(
        baseTheme: baseTheme,
        textScaleFactor: textScaleFactor,
      );
    }

    return baseTheme;
  }
}
