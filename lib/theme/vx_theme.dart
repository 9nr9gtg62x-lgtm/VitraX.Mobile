import 'package:flutter/material.dart';

/// VitraX brand tokens — mirrors the colors used in the ASP.NET MVC dashboard
/// (VitraX.MVC/wwwroot/css/vitrax.css) so the web and mobile apps read as one product.
class VxColors {
  static const primary = Color(0xFF00685F);
  static const primaryContainer = Color(0xFF008378);
  static const secondary = Color(0xFF006B5F);
  static const secondaryFixed = Color(0xFF71F8E4);
  static const tertiary = Color(0xFF5F74A1);
  static const navy = Color(0xFF0F2850);
  static const surface = Color(0xFFF8F9FA);
  static const surfaceContainerLow = Color(0xFFF3F4F5);
  static const onSurface = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF3D4947);
  static const outlineVariant = Color(0xFFBCC9C6);
  static const error = Color(0xFFBA1A1A);
}

class VxTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      colorScheme: ColorScheme.fromSeed(
        seedColor: VxColors.primary,
        primary: VxColors.primary,
        secondary: VxColors.secondary,
        tertiary: VxColors.tertiary,
        error: VxColors.error,
        surface: VxColors.surface,
      ),
      scaffoldBackgroundColor: VxColors.surface,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: VxColors.surface,
        foregroundColor: VxColors.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: VxColors.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: VxColors.outlineVariant.withValues(alpha: .4)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VxColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VxColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: VxColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: VxColors.navy),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}

/// Status pill colors shared by Orders / Tasks lists.
Color vxStatusColor(String status) {
  switch (status) {
    case 'مكتمل':
      return VxColors.tertiary;
    case 'متوقف':
      return VxColors.error;
    default:
      return VxColors.secondary;
  }
}
