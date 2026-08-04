import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'profile_photo_provider.dart';

class ProfileAvatar extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final initials = name.isNotEmpty ? name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase() : '?';

    final Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size / 4), // slightly rounded box like React ERP
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: photoId != null
          ? ref.watch(profilePhotoProvider(photoId!)).when(
                data: (bytes) {
                  if (bytes != null) {
                    return Image.memory(
                      bytes,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildInitials(initials),
                    );
                  }
                  return _buildInitials(initials);
                },
                loading: () => const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (_, _) => _buildInitials(initials),
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
