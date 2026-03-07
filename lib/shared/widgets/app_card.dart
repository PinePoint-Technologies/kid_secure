import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;
  final double borderRadius;
  final BorderSide? border;
  final List<BoxShadow>? shadows;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.onTap,
    this.borderRadius = 20,
    this.border,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = color ??
        (isDark ? AppColors.surfaceDark : AppColors.surface);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border != null
            ? Border.fromBorderSide(border!)
            : Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
                width: 1,
              ),
        boxShadow: shadows ??
            [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 51 : 13),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(padding: padding!, child: child),
              ),
            )
          : Padding(padding: padding!, child: child),
    );
  }
}
