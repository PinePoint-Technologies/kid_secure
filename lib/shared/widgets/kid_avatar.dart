import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class KidAvatar extends StatelessWidget {
  final String? photoUrl;
  final String initials;
  final double size;
  final Color? backgroundColor;

  const KidAvatar({
    super.key,
    this.photoUrl,
    required this.initials,
    this.size = 48,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primaryLight;
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _placeholder(bg),
          errorWidget: (_, __, ___) => _placeholder(bg),
        ),
      );
    }
    return _placeholder(bg);
  }

  Widget _placeholder(Color bg) => CircleAvatar(
        radius: size / 2,
        backgroundColor: bg,
        child: Text(
          initials,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            fontSize: size * 0.33,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}
