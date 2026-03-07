import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/settings_provider.dart';

class TermsScreen extends ConsumerWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consent = ref.watch(settingsProvider).policyConsent;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Terms of Use'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              children: const [
                _Section(
                  heading: '1. Acceptance of Terms',
                  body:
                      'By accessing and using KidSecure, you accept and agree to be bound '
                      'by the terms and provisions of this agreement. If you do not agree '
                      'to these terms, please do not use this application.',
                ),
                _Section(
                  heading: '2. Use of the Application',
                  body:
                      'KidSecure is designed exclusively for authorised crèche staff, '
                      'parents, and guardians. You agree to use this application only for '
                      'lawful purposes and in accordance with these Terms.',
                ),
                _Section(
                  heading: '3. User Accounts',
                  body:
                      'You are responsible for maintaining the confidentiality of your '
                      'account credentials. You agree to notify us immediately of any '
                      'unauthorised use of your account. We reserve the right to '
                      'deactivate accounts that violate these Terms.',
                ),
                _Section(
                  heading: '4. Children\'s Data',
                  body:
                      'KidSecure processes personal data of children in compliance with '
                      'applicable data protection legislation, including the Protection of '
                      'Personal Information Act (POPIA). Crèche administrators are '
                      'responsible for obtaining appropriate consents from parents/guardians '
                      'before onboarding children to the platform.',
                ),
                _Section(
                  heading: '5. Acceptable Use',
                  body:
                      'You must not misuse the application. Prohibited activities include '
                      'attempting to gain unauthorised access, uploading malicious content, '
                      'sharing your access credentials, or using the app for any unlawful '
                      'purpose.',
                ),
                _Section(
                  heading: '6. Intellectual Property',
                  body:
                      'All content, features, and functionality of KidSecure are owned '
                      'by the respective rights holders and are protected by copyright '
                      'and other intellectual property laws.',
                ),
                _Section(
                  heading: '7. Limitation of Liability',
                  body:
                      'KidSecure is provided on an "as is" basis. To the maximum extent '
                      'permitted by law, we exclude all liability for damages arising from '
                      'your use of the application.',
                ),
                _Section(
                  heading: '8. Changes to Terms',
                  body:
                      'We reserve the right to modify these Terms at any time. Continued '
                      'use of the application after changes constitutes acceptance of '
                      'the revised Terms.',
                ),
                _Section(
                  heading: '9. Governing Law',
                  body:
                      'These Terms are governed by the laws of the Republic of South Africa. '
                      'Any disputes shall be resolved in the courts of South Africa.',
                ),
                SizedBox(height: 20),
              ],
            ),
          ),

          // Consent footer
          _ConsentFooter(
            consent: consent,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setPolicyConsent(v),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable section widget ──────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String heading;
  final String body;

  const _Section({required this.heading, required this.body});

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

// ─── Consent footer shared with privacy screen ───────────────────────────────

class _ConsentFooter extends StatelessWidget {
  final bool consent;
  final ValueChanged<bool> onChanged;

  const _ConsentFooter({required this.consent, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: consent,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppColors.primary,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(!consent),
              child: Text(
                'I have read and agree to the Terms of Use '
                'and Data Privacy Policy.',
                style: AppTextStyles.body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
