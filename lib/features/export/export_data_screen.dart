import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../core/db/database_helper.dart';
import '../../shared/theme/app_theme.dart';

/// Export data screen
/// Export financial data to CSV files
class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  bool _isExporting = false;
  String? _lastExportPath;

  Future<void> _exportExpenses() async {
    setState(() => _isExporting = true);

    try {
      // Query expenses with joins
      final expenses = await _db.rawQuery('''
        SELECT 
          e.id,
          e.amount,
          c.name as category,
          a.name as account,
          e.expense_date,
          e.note,
          e.is_auto_detected
        FROM expenses e
        LEFT JOIN categories c ON e.category_id = c.id
        LEFT JOIN accounts a ON e.account_id = a.id
        ORDER BY e.expense_date DESC
      ''');

      // Convert to CSV
      final List<List<dynamic>> rows = [];

      // Header
      rows.add([
        'ID',
        'Date',
        'Amount',
        'Category',
        'Account',
        'Note',
        'Auto-Detected',
      ]);

      // Data rows
      for (final expense in expenses) {
        final date = DateTime.fromMillisecondsSinceEpoch(
          expense['expense_date'] as int,
        );
        final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(date);

        rows.add([
          expense['id'],
          dateStr,
          expense['amount'],
          expense['category'] ?? 'Unknown',
          expense['account'] ?? 'Unknown',
          expense['note'] ?? '',
          (expense['is_auto_detected'] as int) == 1 ? 'Yes' : 'No',
        ]);
      }

      await _saveCsvFile('expenses', rows);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error exporting expenses: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportIncome() async {
    setState(() => _isExporting = true);

    try {
      final income = await _db.rawQuery('''
        SELECT 
          i.id,
          i.amount,
          s.name as source,
          a.name as account,
          i.received_date,
          i.note
        FROM income i
        LEFT JOIN income_sources s ON i.source_id = s.id
        LEFT JOIN accounts a ON i.account_id = a.id
        ORDER BY i.received_date DESC
      ''');

      final List<List<dynamic>> rows = [];
      rows.add(['ID', 'Date', 'Amount', 'Source', 'Account', 'Note']);

      for (final record in income) {
        final date = DateTime.fromMillisecondsSinceEpoch(
          record['received_date'] as int,
        );
        final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(date);

        rows.add([
          record['id'],
          dateStr,
          record['amount'],
          record['source'] ?? 'Unknown',
          record['account'] ?? 'Unknown',
          record['note'] ?? '',
        ]);
      }

      await _saveCsvFile('income', rows);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error exporting income: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportCategories() async {
    setState(() => _isExporting = true);

    try {
      final categories = await _db.query('categories', orderBy: 'name ASC');

      final List<List<dynamic>> rows = [];
      rows.add(['ID', 'Name', 'Icon', 'Monthly Budget', 'Warning Threshold']);

      for (final cat in categories) {
        rows.add([
          cat['id'],
          cat['name'],
          cat['icon'],
          cat['monthly_budget'],
          cat['warning_threshold'],
        ]);
      }

      await _saveCsvFile('categories', rows);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting categories: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportFunds() async {
    setState(() => _isExporting = true);

    try {
      final funds = await _db.query('funds', orderBy: 'name ASC');

      final List<List<dynamic>> rows = [];
      rows.add([
        'ID',
        'Name',
        'Label',
        'Storage Type',
        'Target Amount',
        'Target Date',
        'Active',
      ]);

      for (final fund in funds) {
        final targetDate = fund['target_date'] != null
            ? DateFormat('yyyy-MM-dd').format(
                DateTime.fromMillisecondsSinceEpoch(fund['target_date'] as int),
              )
            : '';

        rows.add([
          fund['id'],
          fund['name'],
          fund['label'],
          fund['storage_type'],
          fund['target_amount'],
          targetDate,
          (fund['is_active'] as int) == 1 ? 'Yes' : 'No',
        ]);
      }

      await _saveCsvFile('funds', rows);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error exporting funds: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportAll() async {
    setState(() => _isExporting = true);

    try {
      await _exportExpenses();
      await _exportIncome();
      await _exportCategories();
      await _exportFunds();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _saveCsvFile(String name, List<List<dynamic>> rows) async {
    try {
      // Convert to CSV string
      final csv = const ListToCsvConverter().convert(rows);

      // Get Downloads directory (fallback to external storage for Android)
      Directory? directory = await getDownloadsDirectory();
      if (directory == null) {
        // Fallback for Android - use external storage Downloads
        directory = await getExternalStorageDirectory();
        if (directory != null) {
          // Navigate to Downloads folder
          final downloadsPath = directory.path.replaceAll(
            RegExp(r'/Android/data/[^/]+/files'),
            '/Download',
          );
          directory = Directory(downloadsPath);
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
        }
      }

      if (directory == null) {
        throw Exception('Could not access Downloads folder');
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'spendsafe_${name}_$timestamp.csv';
      final filePath = '${directory.path}/$fileName';

      // Write file
      final file = File(filePath);
      await file.writeAsString(csv);

      setState(() => _lastExportPath = filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported $name to:\\n$filePath'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Data')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Export your data to CSV files for backup or analysis in spreadsheet software.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade900,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Export Options',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          // Export expenses
          _buildExportCard(
            icon: Icons.shopping_cart,
            iconColor: Colors.red,
            title: 'Export Expenses',
            subtitle: 'All expense transactions with categories',
            onTap: _isExporting ? null : _exportExpenses,
          ),
          const SizedBox(height: 12),

          // Export income
          _buildExportCard(
            icon: Icons.arrow_downward,
            iconColor: Colors.green,
            title: 'Export Income',
            subtitle: 'All income records with sources',
            onTap: _isExporting ? null : _exportIncome,
          ),
          const SizedBox(height: 12),

          // Export categories
          _buildExportCard(
            icon: Icons.category,
            iconColor: Colors.orange,
            title: 'Export Categories',
            subtitle: 'Category list with budgets',
            onTap: _isExporting ? null : _exportCategories,
          ),
          const SizedBox(height: 12),

          // Export funds
          _buildExportCard(
            icon: Icons.savings,
            iconColor: Colors.purple,
            title: 'Export Funds',
            subtitle: 'Sinking funds with targets',
            onTap: _isExporting ? null : _exportFunds,
          ),
          const SizedBox(height: 24),

          // Export all button
          ElevatedButton.icon(
            onPressed: _isExporting ? null : _exportAll,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
            ),
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.file_download, color: Colors.white),
            label: Text(
              _isExporting ? 'Exporting...' : 'Export All Data',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),

          if (_lastExportPath != null) ...[
            const SizedBox(height: 24),
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
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Last Export',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _lastExportPath!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade800,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExportCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
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
              child: Icon(icon, size: 22, color: iconColor),
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
                      color: AppTheme.textSecondary.withAlpha(
                        (0.8 * 255).toInt(),
                      ),
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
