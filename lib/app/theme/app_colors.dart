import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary — Azul confianza
  static const Color primary = Color(0xFF1A56DB);
  static const Color primaryLight = Color(0xFF4B7BF5);
  static const Color primaryDark = Color(0xFF1240A8);
  static const Color primarySurface = Color(0xFFEEF2FF);

  // Secondary — Naranja energía
  static const Color secondary = Color(0xFFF97316);
  static const Color secondaryLight = Color(0xFFFB923C);
  static const Color secondaryDark = Color(0xFFEA6D00);
  static const Color secondarySurface = Color(0xFFFFF7ED);

  // Success
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFF4ADE80);
  static const Color successSurface = Color(0xFFF0FDF4);

  // Warning
  static const Color warning = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFFFBEB);

  // Error
  static const Color error = Color(0xFFDC2626);
  static const Color errorSurface = Color(0xFFFEF2F2);

  // Neutrals
  static const Color black = Color(0xFF0F172A);
  static const Color grey900 = Color(0xFF1E293B);
  static const Color grey800 = Color(0xFF334155);
  static const Color grey700 = Color(0xFF475569);
  static const Color grey600 = Color(0xFF64748B);
  static const Color grey500 = Color(0xFF94A3B8);
  static const Color grey400 = Color(0xFFCBD5E1);
  static const Color grey300 = Color(0xFFE2E8F0);
  static const Color grey200 = Color(0xFFF1F5F9);
  static const Color grey100 = Color(0xFFF8FAFC);
  static const Color white = Color(0xFFFFFFFF);

  // Background
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Category colors
  static const Color catMechanico = Color(0xFFEF4444);
  static const Color catAlbanil = Color(0xFFF97316);
  static const Color catElectricista = Color(0xFFEAB308);
  static const Color catSoldador = Color(0xFF3B82F6);
  static const Color catPlomero = Color(0xFF22C55E);

  // Status colors
  static const Color statusAvailable = Color(0xFF16A34A);
  static const Color statusBusy = Color(0xFFD97706);
  static const Color statusOffline = Color(0xFF94A3B8);
  static const Color statusVerified = Color(0xFF1A56DB);

  // Overlay
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x1A000000);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A56DB), Color(0xFF4B7BF5)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A56DB), Color(0xFF6366F1)],
  );
}
