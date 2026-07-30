import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static final display = GoogleFonts.geist(
    fontSize: 30, // 3xl
    height: 36 / 30,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.02,
  );
  
  static final headline = GoogleFonts.geist(
    fontSize: 24, // 2xl
    height: 32 / 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.02,
  );
  
  static final title = GoogleFonts.geist(
    fontSize: 20, // xl
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01,
  );

  static final subtitle = GoogleFonts.geist(
    fontSize: 18, // lg
    height: 28 / 18,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.01,
  );

  static final body = GoogleFonts.inter(
    fontSize: 16, // base
    height: 24 / 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  );

  static final button = GoogleFonts.inter(
    fontSize: 14, // sm
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static final label = GoogleFonts.inter(
    fontSize: 14, // sm
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static final caption = GoogleFonts.inter(
    fontSize: 12, // xs
    height: 16 / 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  );
}
