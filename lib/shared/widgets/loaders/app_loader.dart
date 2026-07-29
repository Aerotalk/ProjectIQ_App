import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final Color? color;
  
  const AppLoader({
    Key? key,
    this.size = AppSpacing.s24,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final loaderColor = color ?? (isDark ? AppColors.primaryDark : AppColors.primaryLight);
    
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 3.0,
          valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
        ),
      ),
    );
  }
}
