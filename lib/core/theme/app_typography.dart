import 'package:flutter/material.dart';

class AppTypography {
  static const String _fontFamily = 'Inter'; // Default ERP font

  static const display = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 30, // 3xl
    height: 36 / 30,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.02,
  );
  
  static const headline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24, // 2xl
    height: 32 / 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.02,
  );
  
  static const title = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20, // xl
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01,
  );

  static const subtitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18, // lg
    height: 28 / 18,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.01,
  );

  static const body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16, // base
    height: 24 / 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  );

  static const button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14, // sm
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static const label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14, // sm
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static const caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12, // xs
    height: 16 / 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  );
}
