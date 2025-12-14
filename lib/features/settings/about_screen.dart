import 'package:flutter/material.dart';
import '../../shared/theme/app_theme.dart';

/// About/Help screen
/// Information about the app and its features
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About SpendSafe'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // App icon/logo placeholder
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0066FF), Color(0xFF0052CC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'SpendSafe',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Personal Finance Assistant',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary.withAlpha((0.8 * 255).toInt()),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // What is SpendSafe
          const Text(
            'What is SpendSafe?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Text(
              'SpendSafe is a cash-flow first personal finance app that helps you track your spending, manage budgets, and achieve your savings goals. Unlike traditional banking apps, SpendSafe shows you exactly how much you can safely spend today.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade900,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Key Features
          const Text(
            'Key Features',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.payments,
            color: Colors.green,
            title: 'Freedom to Spend (FTS)',
            description: 'See how much money you can actually spend without worry',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.speed,
            color: Colors.orange,
            title: 'Safe Pace',
            description: 'Know your recommended daily spending to stay on track',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.category,
            color: Colors.purple,
            title: 'Advisory Budgets',
            description: 'Budget warnings that guide without blocking your spending',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.savings,
            color: Colors.blue,
            title: 'Sinking Funds',
            description: 'Save for goals systematically with visual progress tracking',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.people,
            color: Colors.red,
            title: 'Debts & Dues',
            description: 'Track money you owe and money owed to you',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.insights,
            color: Colors.teal,
            title: 'Visual Analytics',
            description: 'Beautiful charts showing where your money goes',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.file_download,
            color: Colors.cyan,
            title: 'Data Export',
            description: 'Export your data to CSV for backup and analysis',
          ),
          const SizedBox(height: 32),
          
          // Philosophy
          const Text(
            'Our Philosophy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 Cash-Flow First',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Focus on what you can spend today, not just what you have',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green.shade800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '🎯 Advisory, Not Blocking',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Budgets warn you when you\'re overspending, but never block transactions',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green.shade800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '🔒 Your Data, Your Control',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'All data stored locally. Export anytime to CSV for complete ownership',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green.shade800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Contact/Support (placeholder)
          const Text(
            'Support',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help? Have feedback?',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary.withAlpha((0.9 * 255).toInt()),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Email: support@spendsafe.app',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha((0.1 * 255).toInt()),
              borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withAlpha((0.8 * 255).toInt()),
                    height: 1.3,
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
