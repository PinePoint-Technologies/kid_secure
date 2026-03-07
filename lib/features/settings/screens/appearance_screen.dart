import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/theme_provider.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Appearance'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Theme', style: AppTextStyles.label),
          const SizedBox(height: 12),
          ..._ThemeOption.values.asMap().entries.map((e) {
            final opt = e.value;
            final isSelected = currentMode == opt.mode;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ThemeCard(
                option: opt,
                isSelected: isSelected,
                onTap: () =>
                    ref.read(themeProvider.notifier).setTheme(opt.mode),
              ).animate(delay: (e.key * 80).ms).fadeIn(duration: 300.ms),
            );
          }),

          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withAlpha(80)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.info, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selecting "System Default" will automatically switch '
                    'between light and dark based on your device setting.',
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ).animate(delay: 280.ms).fadeIn(duration: 300.ms),
        ],
      ),
    );
  }
}

// ─── Theme options enum ───────────────────────────────────────────────────────

enum _ThemeOption {
  light(ThemeMode.light, 'Light', Icons.light_mode_rounded,
      'Bright and clean interface'),
  dark(ThemeMode.dark, 'Dark', Icons.dark_mode_rounded,
      'Easy on the eyes at night'),
  system(ThemeMode.system, 'System Default', Icons.settings_suggest_rounded,
      'Follows your device theme');

  final ThemeMode mode;
  final String label;
  final IconData icon;
  final String description;

  const _ThemeOption(this.mode, this.label, this.icon, this.description);
}

// ─── Theme card with preview ──────────────────────────────────────────────────

class _ThemeCard extends StatelessWidget {
  final _ThemeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(40),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Mini preview
            _Preview(option: option),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.label, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 4),
                  Text(option.description, style: AppTextStyles.caption),
                ],
              ),
            ),
            // Selection indicator
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppColors.primary, key: ValueKey(true))
                  : Icon(Icons.radio_button_unchecked_rounded,
                      color: AppColors.border, key: const ValueKey(false)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  final _ThemeOption option;

  const _Preview({required this.option});

  @override
  Widget build(BuildContext context) {
    final isDark = option.mode == ThemeMode.dark ||
        (option.mode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    final bg = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final card = isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF5F5F5);
    final text = isDark ? Colors.white : const Color(0xFF1B2D4F);
    final accent = AppColors.primary;

    return Container(
      width: 60,
      height: 64,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withAlpha(80)),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fake app bar
          Row(
            children: [
              Container(
                  width: 12, height: 12, color: accent,
                  margin: const EdgeInsets.only(right: 4)),
              Expanded(
                child: Container(height: 4, color: text.withAlpha(180)),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Fake card
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 36,
            height: 6,
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 5),
          // Fake button
          Container(
            width: double.infinity,
            height: 10,
            decoration: BoxDecoration(
              color: accent.withAlpha(200),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
