import 'package:flutter/material.dart';

void main() {
  String hslToHex(double h, double s, double l) {
    final color = HSLColor.fromAHSL(1.0, h, s / 100, l / 100).toColor();
    return '0xFF${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  final lightColors = {
    'background': [0.0, 0.0, 100.0],
    'foreground': [240.0, 10.0, 3.9],
    'card': [0.0, 0.0, 100.0],
    'cardForeground': [240.0, 10.0, 3.9],
    'popover': [0.0, 0.0, 100.0],
    'popoverForeground': [240.0, 10.0, 3.9],
    'primary': [322.0, 55.0, 31.0],
    'primaryForeground': [0.0, 0.0, 98.0],
    'secondary': [240.0, 4.8, 95.9],
    'secondaryForeground': [240.0, 5.9, 10.0],
    'muted': [240.0, 4.8, 95.9],
    'mutedForeground': [240.0, 3.8, 46.1],
    'accent': [240.0, 4.8, 95.9],
    'accentForeground': [240.0, 5.9, 10.0],
    'destructive': [0.0, 84.2, 60.2],
    'border': [240.0, 5.9, 90.0],
    'input': [240.0, 5.9, 90.0],
    'ring': [322.0, 55.0, 31.0],
    'chart1': [12.0, 76.0, 61.0],
    'chart2': [173.0, 58.0, 39.0],
    'chart3': [197.0, 37.0, 24.0],
    'chart4': [43.0, 74.0, 66.0],
    'chart5': [27.0, 87.0, 67.0],
    'sidebar': [0.0, 0.0, 98.0],
    'sidebarForeground': [240.0, 5.3, 26.1],
    'sidebarPrimary': [240.0, 5.9, 10.0],
    'sidebarPrimaryForeground': [0.0, 0.0, 98.0],
    'sidebarAccent': [240.0, 4.8, 95.9],
    'sidebarAccentForeground': [240.0, 5.9, 10.0],
    'sidebarBorder': [220.0, 13.0, 91.0],
    'sidebarRing': [217.2, 91.2, 59.8]
  };

  final darkColors = {
    'background': [240.0, 10.0, 3.9],
    'foreground': [0.0, 0.0, 98.0],
    'card': [240.0, 10.0, 3.9],
    'cardForeground': [0.0, 0.0, 98.0],
    'popover': [240.0, 10.0, 3.9],
    'popoverForeground': [0.0, 0.0, 98.0],
    'primary': [0.0, 0.0, 98.0],
    'primaryForeground': [240.0, 5.9, 10.0],
    'secondary': [240.0, 3.7, 15.9],
    'secondaryForeground': [0.0, 0.0, 98.0],
    'muted': [240.0, 3.7, 15.9],
    'mutedForeground': [240.0, 5.0, 64.9],
    'accent': [240.0, 3.7, 15.9],
    'accentForeground': [0.0, 0.0, 98.0],
    'destructive': [0.0, 62.8, 30.6],
    'border': [240.0, 3.7, 15.9],
    'input': [240.0, 3.7, 15.9],
    'ring': [240.0, 4.9, 83.9],
    'chart1': [220.0, 70.0, 50.0],
    'chart2': [160.0, 60.0, 45.0],
    'chart3': [30.0, 80.0, 55.0],
    'chart4': [280.0, 65.0, 60.0],
    'chart5': [340.0, 75.0, 55.0],
    'sidebar': [240.0, 5.9, 10.0],
    'sidebarForeground': [240.0, 4.8, 95.9],
    'sidebarPrimary': [224.3, 76.3, 48.0],
    'sidebarPrimaryForeground': [0.0, 0.0, 100.0],
    'sidebarAccent': [240.0, 3.7, 15.9],
    'sidebarAccentForeground': [240.0, 4.8, 95.9],
    'sidebarBorder': [240.0, 3.7, 15.9],
    'sidebarRing': [217.2, 91.2, 59.8]
  };

  print('''import 'package:flutter/material.dart';

class AppColors {
  // LIGHT MODE''');
  
  lightColors.forEach((key, val) {
    print('  static const ${key}Light = Color(${hslToHex(val[0], val[1], val[2])});');
  });

  print('\n  // DARK MODE');
  darkColors.forEach((key, val) {
    print('  static const ${key}Dark = Color(${hslToHex(val[0], val[1], val[2])});');
  });
  
  print('}');
}
