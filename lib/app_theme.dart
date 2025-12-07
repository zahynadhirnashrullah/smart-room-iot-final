import 'package:flutter/material.dart';

class AppTheme {
  // Background
  static const Color background = Color(0xFFF0F4F8); // Putih kebiruan (Clean)

  // Gradients untuk Header (Kesan Mewah)
  static const LinearGradient safeGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF69F0AE)], // Hijau Emerald ke Neon
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFD32F2F), Color(0xFFFF5252)], // Merah darah ke terang
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card Colors
  static const Color cardColor = Colors.white;
  static Color shadowColor = const Color(0xFF90A4AE).withOpacity(0.2);
}
