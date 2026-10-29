// SPDX-License-Identifier: MIT
// The app in spezado's brand (spezado/brand/README.md): deep-sea petrol and copper bronze as equals, paper in light
// mode, night in dark mode; headings in Domitian (bundled, OFL-1.1), text in the system font.

import 'package:flutter/material.dart';

/// The colours of one appearance.
class Brand extends ThemeExtension<Brand> {
  const Brand({
    required this.background,
    required this.surface,
    required this.text,
    required this.muted,
    required this.accent,
    required this.onAccent,
    required this.line,
    required this.error,
  });

  static const light = Brand(
    background: Color(0xFFF4EEE8),
    surface: Color(0xFFFFFFFF),
    text: Color(0xFF0A2C33),
    muted: Color(0xFF4E6266),
    accent: Color(0xFF985A34),
    onAccent: Color(0xFFF4EEE8),
    line: Color(0x240A2C33),
    error: Color(0xFFA3322A),
  );

  static const dark = Brand(
    background: Color(0xFF071F25),
    surface: Color(0xFF0D2A31),
    text: Color(0xFFF4EEE8),
    muted: Color(0xFF9FB2B4),
    accent: Color(0xFFD59A70),
    onAccent: Color(0xFF071F25),
    line: Color(0x24F4EEE8),
    error: Color(0xFFF0907F),
  );

  final Color background, surface, text, muted, accent, onAccent, line, error;

  static Brand of(BuildContext context) => Theme.of(context).extension<Brand>()!;

  @override
  Brand copyWith() => this;

  @override
  Brand lerp(Brand? other, double t) => t < 0.5 || other == null ? this : other;
}

const serif = 'Domitian';

ThemeData theme(Brightness brightness) {
  final brand = brightness == Brightness.light ? Brand.light : Brand.dark;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: brand.accent,
    onPrimary: brand.onAccent,
    secondary: brand.text,
    onSecondary: brand.background,
    error: brand.error,
    onError: brand.onAccent,
    surface: brand.surface,
    onSurface: brand.text,
    onSurfaceVariant: brand.muted,
    outline: brand.line,
    outlineVariant: brand.line,
    surfaceContainerLowest: brand.background,
    surfaceContainerLow: brand.surface,
    surfaceContainer: brand.surface,
    surfaceContainerHigh: brand.surface,
    surfaceContainerHighest: brand.surface,
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true, brightness: brightness);
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(6));
  const padding = EdgeInsets.symmetric(horizontal: 14, vertical: 12);
  TextStyle? heading(TextStyle? style) =>
      style?.copyWith(fontFamily: serif, fontWeight: FontWeight.w700, color: brand.text);
  return base.copyWith(
    scaffoldBackgroundColor: brand.background,
    extensions: [brand],
    dividerColor: brand.line,
    dividerTheme: DividerThemeData(color: brand.line, space: 1),
    textTheme: base.textTheme.copyWith(
      headlineMedium: heading(base.textTheme.headlineSmall),
      titleLarge: heading(base.textTheme.titleLarge),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: brand.surface,
      foregroundColor: brand.text,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: brand.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: brand.line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: brand.surface,
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: brand.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: brand.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: brand.accent, width: 2),
      ),
      labelStyle: TextStyle(color: brand.muted),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(shape: shape, padding: padding),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: shape,
        padding: padding,
        foregroundColor: brand.text,
        side: BorderSide(color: brand.line),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: brand.surface,
      indicatorColor: brand.accent.withValues(alpha: 0.16),
      selectedIconTheme: IconThemeData(color: brand.accent),
      selectedLabelTextStyle: TextStyle(color: brand.accent, fontWeight: FontWeight.w600),
      unselectedLabelTextStyle: TextStyle(color: brand.text),
    ),
    dataTableTheme: DataTableThemeData(
      headingTextStyle: TextStyle(color: brand.muted, fontWeight: FontWeight.w600, fontSize: 13),
      dividerThickness: 1,
    ),
  );
}
