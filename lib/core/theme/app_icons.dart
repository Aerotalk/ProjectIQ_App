import 'package:flutter/material.dart';

class AppIcons {
  // Standard icon sizes
  static const double sm = 16.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  /// Creates a standard icon widget matching the ERP design system.
  static Widget standard(
    IconData icon, {
    double size = md,
    Color? color,
  }) {
    return Icon(
      icon,
      size: size,
      color: color,
    );
  }
}
