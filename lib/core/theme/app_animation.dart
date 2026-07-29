import 'package:flutter/material.dart';

class AppAnimation {
  // Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration verySlow = Duration(milliseconds: 500);

  // Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  
  // Specific transitions
  static const Duration dialogDuration = Duration(milliseconds: 200);
  static const Duration bottomSheetDuration = Duration(milliseconds: 250);
  static const Duration buttonPressDuration = Duration(milliseconds: 100);
}
