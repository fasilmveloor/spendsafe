import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/expense.dart';
import '../../core/models/category.dart';
import '../../shared/theme/app_theme.dart';
import '../../core/db/database_helper.dart';
import 'edit_transaction_screen.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Expense expense;
  final Category category;

  const TransactionDetailScreen({
    super.key,
    required this.expense,
    required this.category,
  });

  Future<void> _deleteTransaction(BuildContext context) async {
    final db = DatabaseHelper.instance;
    await db.delete('expenses', where: 'id = ?', whereArgs: [expense.id]);

    // TODO: If linked to a Fund, revert the fund progress
    // TODO: If linked to a Debt (Due), revert the status

    if (context.mounted) {
      Navigator.pop(context); // Close dialog
      Navigator.pop(context, true); // Close screen and return true
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: Text(
          'This will increase your Available to Spend by ${currencyFormat.format(expense.amount).replaceAll('.00', '')}.\n\nAre you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _deleteTransaction(context),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTransactionScreen(
                    expense: expense,
                    category: category,
                  ),
                ),
              );
              if (context.mounted) {
                Navigator.pop(
                  context,
                  true,
                ); // Return true to refresh on back from edit
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      category.icon ?? '📝',
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currencyFormat.format(expense.amount).replaceAll('.00', ''),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildDetailItem('Date', dateFormat.format(expense.expenseDate)),
            if (expense.note != null && expense.note!.isNotEmpty) ...[
              const Divider(height: 32),
              _buildDetailItem('Note', expense.note!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
