import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_card.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  final _feedbackCtrl = TextEditingController();
  bool _feedbackSent = false;

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ─── FAQ ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text('Frequently Asked Questions', style: AppTextStyles.label),
          ),
          AppCard(
            child: Column(
              children: _faqs.asMap().entries.map((e) {
                final isLast = e.key == _faqs.length - 1;
                return Column(
                  children: [
                    _FaqTile(faq: e.value),
                    if (!isLast) const Divider(height: 1),
                  ],
                );
              }).toList(),
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          // ─── Contact ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text('Contact Support', style: AppTextStyles.label),
          ),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _iconBox(Icons.email_rounded, AppColors.primary),
                  title: Text('Email Support', style: AppTextStyles.bodyMedium),
                  subtitle: Text('support@kidsecure.app',
                      style: AppTextStyles.caption),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: AppColors.textHint),
                  onTap: () => _launch('mailto:support@kidsecure.app'),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _iconBox(Icons.phone_rounded, AppColors.success),
                  title:
                      Text('Phone Support', style: AppTextStyles.bodyMedium),
                  subtitle:
                      Text('+27 10 123 4567', style: AppTextStyles.caption),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: AppColors.textHint),
                  onTap: () => _launch('tel:+27101234567'),
                ),
              ],
            ),
          ).animate(delay: 80.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          // ─── Feedback form ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text('Send Feedback', style: AppTextStyles.label),
          ),
          AppCard(
            child: _feedbackSent
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 40),
                        const SizedBox(height: 8),
                        Text('Thank you for your feedback!',
                            style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 4),
                        Text('We\'ll review it shortly.',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      TextField(
                        controller: _feedbackCtrl,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText:
                              'Tell us what you think or report an issue…',
                          hintStyle: AppTextStyles.caption,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () {
                          if (_feedbackCtrl.text.trim().isEmpty) return;
                          // TODO: send via support email / Firestore
                          setState(() => _feedbackSent = true);
                        },
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('Submit Feedback'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ],
                  ),
          ).animate(delay: 160.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      );
}

// ─── FAQ data ─────────────────────────────────────────────────────────────────

const _faqs = [
  _Faq(
    q: 'How do I sign a child in or out?',
    a: 'Open the Sign In/Out screen from the Home tab. Select the child and '
        'use one of the three methods: Manual, QR Scan, or Guardian PIN.',
  ),
  _Faq(
    q: 'How do I add a trusted guardian?',
    a: 'Go to Guardians tab → tap "Add Guardian". Fill in the guardian\'s '
        'details and set a PIN. The guardian will receive a QR code they '
        'can show at the gate.',
  ),
  _Faq(
    q: 'Why can\'t I see my child\'s attendance?',
    a: 'Make sure your account is linked to your child\'s profile. Contact '
        'the crèche administrator if you are not yet linked.',
  ),
  _Faq(
    q: 'How do I change the app language?',
    a: 'Go to Settings → Language. Select your preferred language and tap '
        '"Apply Language".',
  ),
  _Faq(
    q: 'Is my data secure?',
    a: 'Yes. All data is stored on encrypted Google Firebase servers. '
        'Access is restricted by role-based permissions. '
        'See our Privacy Policy for full details.',
  ),
];

class _Faq {
  final String q;
  final String a;
  const _Faq({required this.q, required this.a});
}

class _FaqTile extends StatefulWidget {
  final _Faq faq;
  const _FaqTile({required this.faq});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 12),
      title: Text(widget.faq.q, style: AppTextStyles.bodyMedium),
      trailing: Icon(
        _expanded
            ? Icons.keyboard_arrow_up_rounded
            : Icons.keyboard_arrow_down_rounded,
        color: AppColors.primary,
      ),
      onExpansionChanged: (v) => setState(() => _expanded = v),
      children: [
        Text(widget.faq.a, style: AppTextStyles.body),
      ],
    );
  }
}
