import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppBorders {
  static const double widthSm = 1.0;
  static const double widthMd = 2.0;
  static const double widthLg = 4.0;

  static Border allLight = Border.all(
    color: AppColors.borderLight,
    width: widthSm,
  );

  static Border allDark = Border.all(
    color: AppColors.borderDark,
    width: widthSm,
  );

  static Border inputLight = Border.all(
    color: AppColors.inputLight,
    width: widthSm,
  );

  static Border inputDark = Border.all(
    color: AppColors.inputDark,
    width: widthSm,
  );
  
  static Border focusLight = Border.all(
    color: AppColors.ringLight,
    width: widthMd,
  );
  
  static Border focusDark = Border.all(
    color: AppColors.ringDark,
    width: widthMd,
  );
}
