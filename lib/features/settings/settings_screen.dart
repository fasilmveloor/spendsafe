import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme/app_theme.dart';
import '../../core/providers/theme_provider.dart';
import '../income/income_overview_screen.dart';

import '../fixed_expenses/fixed_expenses_screen.dart';
import '../alerts/alerts_screen.dart';
import '../export/export_data_screen.dart';
import '../dues/debts_and_dues_screen.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';
import 'help_support_screen.dart';
import 'profile_screen.dart';
import 'backup_screen.dart';

/// Settings/More screen
/// Provides access to additional features and settings
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Profile section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0066FF), Color(0xFF0052CC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 32,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'user@spendsafe.com',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Income & Expenses section
          const Text(
            'Money Management',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            context,
            icon: Icons.arrow_downward,
            iconColor: Colors.green,
            title: 'Income & Sources',
            subtitle: 'Manage income sources and records',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const IncomeOverviewScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            icon: Icons.calendar_today,
            iconColor: Colors.red,
            title: 'Fixed Expenses',
            subtitle: 'Recurring monthly payments',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FixedExpensesScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            icon: Icons.people_outline,
            iconColor: Colors.orange,
            title: 'Debts & Dues',
            subtitle: 'Money owed to/from you',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DebtsAndDuesScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          
          // App settings section
          const Text(
            'App Settings',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            context,
            icon: Icons.notifications_outlined,
            iconColor: AppTheme.primary,
            title: 'Alerts',
            subtitle: 'View system alerts',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AlertsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            icon: Icons.file_download_outlined,
            iconColor: Colors.purple,
            title: 'Export Data',
            subtitle: 'CSV & Excel export',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ExportDataScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            icon: Icons.cloud_upload_outlined,
            iconColor: Colors.teal,
            title: 'Backup & Restore',
            subtitle: 'Google Drive backup',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BackupScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            icon: Icons.palette_outlined,
            iconColor: Colors.pink,
            title: 'Theme',
            subtitle: 'Light or dark mode',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Consumer(
                  builder: (context, ref, _) {
                    final currentTheme = ref.watch(themeProvider);
                    return AlertDialog(
                      title: const Text('Select Theme'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile<ThemeMode>(
                            title: const Text('Generic System'),
                            value: ThemeMode.system,
                            groupValue: currentTheme,
                            onChanged: (value) {
                              ref.read(themeProvider.notifier).setTheme(value!);
                              Navigator.pop(context);
                            },
                          ),
                          RadioListTile<ThemeMode>(
                            title: const Text('Light'),
                            value: ThemeMode.light,
                            groupValue: currentTheme,
                            onChanged: (value) {
                              ref.read(themeProvider.notifier).setTheme(value!);
                              Navigator.pop(context);
                            },
                          ),
                          RadioListTile<ThemeMode>(
                            title: const Text('Dark'),
                            value: ThemeMode.dark,
                            groupValue: currentTheme,
                            onChanged: (value) {
                              ref.read(themeProvider.notifier).setTheme(value!);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          
          // About section
          const Text(
            'About',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            iconColor: AppTheme.textSecondary,
            title: 'Help & Support',
            subtitle: 'Get help using SpendSafe',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            icon: Icons.privacy_tip_outlined,
            iconColor: AppTheme.textSecondary,
            title: 'Privacy & Security',
            subtitle: 'Your data, your control',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            iconColor: AppTheme.textSecondary,
            title: 'About SpendSafe',
            subtitle: 'Version 1.0.0',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withAlpha((0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Icon(
                icon,
                size: 22,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary.withAlpha((0.8 * 255).toInt()),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary.withAlpha((0.5 * 255).toInt()),
            ),
          ],
        ),
      ),
    );
  }
}
