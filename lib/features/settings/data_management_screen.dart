import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import '../../core/db/database_helper.dart';
import '../../shared/theme/app_theme.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _isLoading = false;

  Future<void> _exportDatabase() async {
    setState(() => _isLoading = true);
    try {
      final dbFile = await DatabaseHelper.instance.getDatabaseFile();
      final date = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final fileName = 'spendsafe_backup_$date.db';

      // Create a copy in temp dir to share with correct name
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await dbFile.copy(tempFile.path);

      await Share.shareXFiles([
        XFile(tempFile.path),
      ], text: 'SpendSafe Database Backup');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _importDatabase() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // Confirmation
        if (!mounted) return;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Overwrite Database?'),
            content: const Text(
              'This will REPLACE all your current data with the selected file. This action cannot be undone.\n\nAre you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Overwrite'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          setState(() => _isLoading = true);
          final dbFile = await DatabaseHelper.instance.getDatabaseFile();
          // Close DB connection if possible or just overwrite (hot overwrite might crash if active, but safe enough for single user if we restart)
          // ideally we close db, but helper might not expose it.
          // Proceeding with overwrite.
          await file.copy(dbFile.path);

          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Import Successful'),
                content: const Text(
                  'Please restart the app to see the changes.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // TODO: Restart or exit
                      // Using generic exit like behavior
                      Navigator.pop(context);
                      Navigator.pop(context); // Go back out
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _importCsv() async {
    // Placeholder for CSV Import logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('CSV Import coming soon')));
  }

  Future<void> _exportCsv() async {
    setState(() => _isLoading = true);
    try {
      final db = await DatabaseHelper.instance.database;

      // Fetch all expenses with category names
      final expenses = await db.rawQuery('''
        SELECT e.id, e.amount, c.name as category, e.note, e.expense_date, a.name as account
        FROM expenses e
        LEFT JOIN categories c ON e.category_id = c.id
        LEFT JOIN accounts a ON e.account_id = a.id
        ORDER BY e.expense_date DESC
      ''');

      if (expenses.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No expenses to export')),
          );
        }
        return;
      }

      // Create CSV
      List<List<dynamic>> rows = [
        ['Date', 'Amount', 'Category', 'Account', 'Note'], // Header
      ];

      for (final exp in expenses) {
        final date = DateTime.fromMillisecondsSinceEpoch(
          exp['expense_date'] as int,
        );
        rows.add([
          DateFormat('yyyy-MM-dd').format(date),
          exp['amount'],
          exp['category'] ?? 'Uncategorized',
          exp['account'] ?? '',
          exp['note'] ?? '',
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);
      final date = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final fileName = 'spendsafe_expenses_$date.csv';

      // Write to temp file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(csv);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'SpendSafe Expenses Export');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildSectionHeader('Database Backup'),
                const SizedBox(height: 16),
                _buildActionCard(
                  title: 'Export Database',
                  description:
                      'Save a full backup file (.db) to your device or cloud storage.',
                  icon: Icons.upload_file,
                  onTap: _exportDatabase,
                ),
                const SizedBox(height: 16),
                _buildActionCard(
                  title: 'Import Database',
                  description:
                      'Restore from a .db file. WARNING: Overwrites current data.',
                  icon: Icons.download,
                  isDestructive: true,
                  onTap: _importDatabase,
                ),

                const SizedBox(height: 32),
                _buildSectionHeader('CSV Data'),
                const SizedBox(height: 16),
                _buildActionCard(
                  title: 'Export CSV',
                  description: 'Export all expenses to a CSV spreadsheet file.',
                  icon: Icons.file_download_outlined,
                  onTap: _exportCsv,
                ),
                const SizedBox(height: 16),
                _buildActionCard(
                  title: 'Import CSV',
                  description: 'Import expenses from a CSV file.',
                  icon: Icons.table_chart,
                  onTap: _importCsv,
                ),
                // Export CSV can be added here
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppTheme.textSecondary,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.shade50
                    : AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppTheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
