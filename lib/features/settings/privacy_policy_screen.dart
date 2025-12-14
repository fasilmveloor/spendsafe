import 'package:flutter/material.dart';
import '../../shared/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSection(
            icon: Icons.security,
            title: 'Data Security',
            content: 'Your financial data is stored locally on your device using secure encryption. SpendSafe does not upload your sensitive financial information to cloud servers without your explicit action (e.g., Google Drive backup).',
          ),
          const SizedBox(height: 24),
          _buildSection(
            icon: Icons.visibility_off,
            title: 'No Tracking',
            content: 'We do not track your spending habits, location, or share your data with third-party advertisers. You are the sole owner of your financial data.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            icon: Icons.phonelink_lock,
            title: 'Device Access',
            content: 'SpendSafe may request access to storage for exporting reports or backups. This access is strictly used for the requested functionality.',
          ),
          const SizedBox(height: 24),
          _buildSection(
            icon: Icons.delete_outline,
            title: 'Data Deletion',
            content: 'You can delete all your data at any time by uninstalling the application or using the "Reset App" option in debugging settings. This action is irreversible.',
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Last updated: December 2025',
              style: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 36),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
