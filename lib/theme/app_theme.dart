import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary     = Color(0xFF059669);
  static const Color primaryDark = Color(0xFF065f46);
  static const Color primaryLight= Color(0xFF10b981);
  static const Color accent      = Color(0xFF6366f1);
  static const Color bgLight     = Color(0xFFF0FDF4);
  static const Color textDark    = Color(0xFF1f2937);
  static const Color textGrey    = Color(0xFF6b7280);
  static const Color textLight   = Color(0xFF9ca3af);
  static const Color red         = Color(0xFFef4444);
  static const Color orange      = Color(0xFFf97316);
  static const Color amber       = Color(0xFFf59e0b);
  static const Color blue        = Color(0xFF3b82f6);
  static const Color indigo      = Color(0xFF6366f1);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Tajawal',
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    scaffoldBackgroundColor: bgLight,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary, foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w900, fontSize: 15),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primary, width: 1.5)),
      hintStyle: const TextStyle(fontFamily: 'Tajawal', color: Color(0xFF9ca3af), fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  static BoxDecoration cardDecoration({double radius = 24, Color? color}) => BoxDecoration(
    color: color ?? Colors.white, borderRadius: BorderRadius.circular(radius),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
  );

  static BoxDecoration gradientHeader() => const BoxDecoration(
    gradient: LinearGradient(colors: [Color(0xFF065f46), Color(0xFF059669), Color(0xFF10b981)],
      begin: Alignment.topLeft, end: Alignment.bottomRight),
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
  );

  static BoxDecoration greenCard() => BoxDecoration(
    gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF0D9488)]),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 6))],
  );
}
