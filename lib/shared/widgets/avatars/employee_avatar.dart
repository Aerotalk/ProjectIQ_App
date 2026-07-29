import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';

class EmployeeAvatar extends StatelessWidget {
  final String? imageUrl;
  final String fallbackInitials;
  final double radius;

  const EmployeeAvatar({
    super.key,
    this.imageUrl,
    required this.fallbackInitials,
    this.radius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? CachedNetworkImageProvider(imageUrl!)
          : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Text(
              fallbackInitials.toUpperCase(),
              style: TextStyle(
                color: AppColors.primaryForegroundLight,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.8,
              ),
            )
          : null,
    );
  }
}
