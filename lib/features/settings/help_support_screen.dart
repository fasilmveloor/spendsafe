import 'package:flutter/material.dart';
import '../../shared/theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          _buildFAQItem(
            question: 'What is "Safe Pace"?',
            answer: 'Safe Pace is your daily spending limit. It is calculated by taking your monthly income, subtracting fixed expenses, and dividing the remainder by the days in the month. Sticking to this pace ensures you never overspend.',
          ),
          _buildFAQItem(
            question: 'How do Funds work?',
            answer: 'Funds are like "envelopes" for saving money. When you add money to a Fund (like "Holiday" or "Emergency"), it is deducted from your Available to Spend immediately, keeping that money safe for its intended purpose.',
          ),
          _buildFAQItem(
            question: 'Can I edit my past transactions?',
            answer: 'Yes! You can tap on any transaction in the list to edit its details, amount, or category. You can also delete erroneous entries.',
          ),
          _buildFAQItem(
            question: 'Is my data backed up?',
            answer: 'By default, data is only stored on your phone. You can manually create a backup to Google Drive or export as CSV from the Settings menu.',
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
            child: Column(
              children: [
                const Icon(Icons.mail_outline, size: 32, color: AppTheme.primary),
                const SizedBox(height: 16),
                const Text(
                  'Still need help?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Contact our support team at:',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'support@spendsafe.com',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
