import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/settings_provider.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consent = ref.watch(settingsProvider).policyConsent;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Data Privacy Policy'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              children: const [
                _PolicySection(
                  heading: '1. Information We Collect',
                  body:
                      'KidSecure collects personal information including names, email '
                      'addresses, phone numbers, and children\'s attendance records. '
                      'We also collect device information and usage data to improve '
                      'the application.',
                ),
                _PolicySection(
                  heading: '2. How We Use Your Information',
                  body:
                      'Your data is used to provide child attendance tracking, parent-teacher '
                      'communication, and safety monitoring features. We do not sell your '
                      'personal information to third parties.',
                ),
                _PolicySection(
                  heading: '3. Data Storage & Security',
                  body:
                      'All data is stored securely on Google Firebase infrastructure with '
                      'encryption at rest and in transit. Access is restricted to authorised '
                      'users based on their assigned roles.',
                ),
                _PolicySection(
                  heading: '4. Children\'s Privacy (COPPA & POPIA)',
                  body:
                      'We are committed to protecting the privacy of children. Personal data '
                      'of children under the age of 13 is processed only with verified '
                      'parental/guardian consent, in compliance with POPIA and applicable '
                      'international standards.',
                ),
                _PolicySection(
                  heading: '5. Data Sharing',
                  body:
                      'Data may be shared with crèche administrators, assigned teachers, '
                      'and the child\'s linked parents/guardians. No data is shared with '
                      'external parties without explicit consent, except where required '
                      'by law.',
                ),
                _PolicySection(
                  heading: '6. Data Retention',
                  body:
                      'We retain personal data for as long as your account is active or as '
                      'needed to provide services. You may request deletion of your data '
                      'by contacting your crèche administrator.',
                ),
                _PolicySection(
                  heading: '7. Your Rights',
                  body:
                      'Under POPIA and GDPR, you have the right to access, correct, and '
                      'request deletion of your personal data. Contact support to exercise '
                      'these rights.',
                ),
                _PolicySection(
                  heading: '8. Cookies & Analytics',
                  body:
                      'The application may use anonymous analytics to understand usage '
                      'patterns. No personally identifiable information is included in '
                      'analytics data.',
                ),
                _PolicySection(
                  heading: '9. Contact',
                  body:
                      'For privacy-related queries, contact us at privacy@kidsecure.app. '
                      'We will respond within 5 business days.',
                ),
                SizedBox(height: 20),
              ],
            ),
          ),

          // Consent footer (shared state with Terms screen)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: consent,
                  onChanged: (v) =>
                      ref.read(settingsProvider.notifier).setPolicyConsent(v ?? false),
                  activeColor: AppColors.primary,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => ref
                        .read(settingsProvider.notifier)
                        .setPolicyConsent(!consent),
                    child: Text(
                      'I have read and agree to the Terms of Use '
                      'and Data Privacy Policy.',
                      style: AppTextStyles.body,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String heading;
  final String body;

  const _PolicySection({required this.heading, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.primary)),
          const SizedBox(height: 6),
          Text(body, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
