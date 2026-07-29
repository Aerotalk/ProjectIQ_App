import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/environment/app_config.dart';

class ProfileAvatar extends StatelessWidget {
  final String name;
  final String? photoId;
  final VoidCallback? onTap;
  final double size;

  const ProfileAvatar({
    super.key,
    required this.name,
    this.photoId,
    this.onTap,
    this.size = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase() : '?';
    final photoUrl = photoId != null ? '${AppConfig.instance.apiBaseUrl}/admin/files/$photoId' : null;

    final Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size / 4), // slightly rounded box like React ERP
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl != null
          ? Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildInitials(initials),
            )
          : _buildInitials(initials),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 4),
        child: avatar,
      );
    }
    
    return avatar;
  }

  Widget _buildInitials(String initials) {
    return Center(
      child: Text(
        initials,
        style: AppTypography.label.copyWith(
          color: AppColors.primaryLight,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
