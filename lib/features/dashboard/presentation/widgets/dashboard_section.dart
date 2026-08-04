import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class DashboardSection extends StatelessWidget {
  final String title;
  final Widget? action;
  final Widget child;

  const DashboardSection({
    super.key,
    required this.title,
    this.action,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.title.copyWith(fontWeight: FontWeight.w700),
              ),
              ?action,
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        child,
      ],
    );
  }
}
