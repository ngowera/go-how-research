// lib/shared/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Static color constants used across the Go-How RS app.
class AppColors {
  AppColors._();

  static const Color kPrimary = Color(0xFF1565C0); // Deep Blue
  static const Color kSecondary = Color(0xFF00897B); // Teal
  static const Color kTertiary = Color(0xFFF57C00); // Orange
  static const Color kSuccess = Color(0xFF2E7D32); // Green
  static const Color kWarning = Color(0xFFF57C00); // Amber-Orange
  static const Color kError = Color(0xFFC62828); // Deep Red
  static const Color kPurple = Color(0xFF7B1FA2); // Purple
  static const Color kInfo = Color(0xFF0277BD); // Light Blue

  static const Color kBackground = Colors.white;
  static const Color kSurface = Color(0xFFF8F9FA);
  static const Color kOnSurface = Color(0xFF1C1B1F);
  static const Color kOutline = Color(0xFFCAC4D0);
}

class AppTheme {
  AppTheme._();

  // Backwards-compatible names used throughout the feature screens.
  static const Color kPrimary = AppColors.kPrimary;
  static const Color kSecondary = AppColors.kSecondary;
  static const Color kTertiary = AppColors.kTertiary;
  static const Color kSuccess = AppColors.kSuccess;
  static const Color kWarning = AppColors.kWarning;
  static const Color kError = AppColors.kError;
  static const Color kPurple = AppColors.kPurple;
  static const Color kInfo = AppColors.kInfo;

  // ---------------------------------------------------------------------------
  // Color Scheme
  // ---------------------------------------------------------------------------
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.kPrimary,
    brightness: Brightness.light,
    primary: AppColors.kPrimary,
    secondary: AppColors.kSecondary,
    tertiary: AppColors.kTertiary,
    error: AppColors.kError,
    background: AppColors.kBackground,
    surface: AppColors.kSurface,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.white,
    onError: Colors.white,
    onBackground: AppColors.kOnSurface,
    onSurface: AppColors.kOnSurface,
    outline: AppColors.kOutline,
  );

  // ---------------------------------------------------------------------------
  // Text Theme (Poppins)
  // ---------------------------------------------------------------------------
  static TextTheme get _poppinsTextTheme => GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
          displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
          displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      );

  // ---------------------------------------------------------------------------
  // Card Theme
  // ---------------------------------------------------------------------------
  static final CardThemeData _cardTheme = CardThemeData(
    elevation: 2,
    shadowColor: Colors.black.withOpacity(0.08),
    surfaceTintColor: Colors.transparent,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: EdgeInsets.zero,
  );

  // ---------------------------------------------------------------------------
  // AppBar Theme
  // ---------------------------------------------------------------------------
  static AppBarTheme _appBarTheme(ColorScheme cs) => AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.kPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.kPrimary),
        actionsIconTheme: const IconThemeData(color: AppColors.kPrimary),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.kPrimary,
        ),
      );

  // ---------------------------------------------------------------------------
  // ElevatedButton Theme
  // ---------------------------------------------------------------------------
  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.kPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // ---------------------------------------------------------------------------
  // OutlinedButton Theme
  // ---------------------------------------------------------------------------
  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.kPrimary,
      side: const BorderSide(color: AppColors.kPrimary, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // ---------------------------------------------------------------------------
  // TextButton Theme
  // ---------------------------------------------------------------------------
  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.kPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // ---------------------------------------------------------------------------
  // Input Decoration Theme
  // ---------------------------------------------------------------------------
  static final InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: AppColors.kSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.kOutline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.kOutline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.kPrimary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.kError),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.kError, width: 2),
    ),
    labelStyle: GoogleFonts.poppins(
      fontSize: 14,
      color: const Color(0xFF6B7280),
    ),
    hintStyle: GoogleFonts.poppins(
      fontSize: 14,
      color: const Color(0xFF9CA3AF),
    ),
    errorStyle: GoogleFonts.poppins(
      fontSize: 12,
      color: AppColors.kError,
    ),
  );

  // ---------------------------------------------------------------------------
  // Chip Theme
  // ---------------------------------------------------------------------------
  static final ChipThemeData _chipTheme = ChipThemeData(
    backgroundColor: AppColors.kSurface,
    selectedColor: AppColors.kPrimary.withOpacity(0.15),
    labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  // ---------------------------------------------------------------------------
  // Divider Theme
  // ---------------------------------------------------------------------------
  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: Color(0xFFE5E7EB),
    thickness: 1,
    space: 1,
  );

  // ---------------------------------------------------------------------------
  // NavigationRail Theme
  // ---------------------------------------------------------------------------
  static NavigationRailThemeData _navigationRailTheme(ColorScheme cs) =>
      NavigationRailThemeData(
        backgroundColor: Colors.white,
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 22),
        unselectedIconTheme:
            const IconThemeData(color: Color(0xFF6B7280), size: 22),
        selectedLabelTextStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        unselectedLabelTextStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF6B7280),
        ),
        indicatorColor: AppColors.kPrimary,
        useIndicator: true,
        elevation: 0,
      );

  // ---------------------------------------------------------------------------
  // Floating Action Button Theme
  // ---------------------------------------------------------------------------
  static const FloatingActionButtonThemeData _fabTheme =
      FloatingActionButtonThemeData(
    backgroundColor: AppColors.kPrimary,
    foregroundColor: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  );

  // ---------------------------------------------------------------------------
  // Public light theme getter
  // ---------------------------------------------------------------------------
  static ThemeData get light {
    final cs = _lightColorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.kBackground,
      textTheme: _poppinsTextTheme,
      cardTheme: _cardTheme,
      appBarTheme: _appBarTheme(cs),
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      chipTheme: _chipTheme,
      dividerTheme: _dividerTheme,
      navigationRailTheme: _navigationRailTheme(cs),
      floatingActionButtonTheme: _fabTheme,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      iconTheme: const IconThemeData(color: AppColors.kPrimary, size: 24),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.kPrimary;
          }
          return const Color(0xFF9CA3AF);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.kPrimary.withOpacity(0.4);
          }
          return const Color(0xFFE5E7EB);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.kPrimary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.kPrimary;
          }
          return const Color(0xFF9CA3AF);
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.kOnSurface,
        ),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF6B7280),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1F2937),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.kPrimary,
        linearTrackColor: Color(0xFFE5E7EB),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.kPrimary,
        unselectedLabelColor: const Color(0xFF6B7280),
        indicatorColor: AppColors.kPrimary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle:
            GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
      ),
    );
  }

  static ThemeData get lightTheme => light;
}
