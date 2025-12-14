import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/db/database_helper.dart';
import '../../core/models/fixed_expense.dart';
import '../../core/models/account.dart';
import '../../shared/theme/app_theme.dart';
import 'add_fixed_expense_screen.dart';

/// Fixed expenses overview screen
/// Displays all recurring monthly expenses
class FixedExpensesScreen extends StatefulWidget {
  const FixedExpensesScreen({super.key});

  @override
  State<FixedExpensesScreen> createState() => _FixedExpensesScreenState();
}

class _FixedExpensesScreenState extends State<FixedExpensesScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  List<Map<String, dynamic>> _fixedExpenses = [];
  double _monthlyTotal = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load fixed expenses with account info
    final expenses = await _db.rawQuery('''
      SELECT f.*, a.name as account_name
      FROM fixed_expenses f
      LEFT JOIN accounts a ON f.account_id = a.id
      ORDER BY f.due_day ASC
    ''');
    
    // Calculate total active fixed expenses
    final totalResult = await _db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM fixed_expenses
      WHERE is_active = 1
    ''');
    
    final total = (totalResult.first['total'] as num?)?.toDouble() ?? 0.0;
    
    setState(() {
      _fixedExpenses = expenses;
      _monthlyTotal = total;
      _isLoading = false;
    });
  }

  Future<void> _toggleActive(FixedExpense expense) async {
    await _db.update(
      'fixed_expenses',
      {'is_active': expense.isActive ? 0 : 1},
      where: 'id = ?',
      whereArgs: [expense.id],
    );
    _loadData();
  }

  Future<void> _deleteExpense(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Fixed Expense'),
        content: const Text('Are you sure you want to delete this fixed expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _db.delete('fixed_expenses', where: 'id = ?', whereArgs: [id]);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixed Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => const AddFixedExpenseScreen(),
                ),
              );
              if (result == true) _loadData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Monthly total card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: Colors.red.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currencyFormat.format(_monthlyTotal).replaceAll('.00', ''),
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total Monthly Fixed Expenses',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
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
                            'Fixed expenses are deducted from your income before calculating Available to Spend',
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
                  
                  // Fixed expenses list
                  const Text(
                    'Monthly Expenses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  if (_fixedExpenses.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: AppTheme.textSecondary,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No fixed expenses yet',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Add recurring monthly payments',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._fixedExpenses.map((record) {
                      final expense = FixedExpense.fromMap(record);
                      final accountName = record['account_name'] as String? ?? 'Unknown';
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: Key('expense_${expense.id}'),
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Fixed Expense'),
                                content: Text('Delete "${expense.name}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (direction) {
                            _db.delete('fixed_expenses', where: 'id = ?', whereArgs: [expense.id]);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                              border: Border.all(
                                color: expense.isActive
                                    ? Colors.grey.shade100
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: expense.isActive
                                        ? Colors.red.shade50
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${expense.dueDay}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: expense.isActive
                                            ? Colors.red.shade700
                                            : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        expense.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: expense.isActive
                                              ? AppTheme.textPrimary
                                              : AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            accountName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary.withAlpha((0.8 * 255).toInt()),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: expense.isActive
                                                  ? Colors.green.shade50
                                                  : Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                                            ),
                                            child: Text(
                                              expense.isActive ? 'Active' : 'Inactive',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: expense.isActive
                                                    ? Colors.green.shade700
                                                    : AppTheme.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      currencyFormat.format(expense.amount).replaceAll('.00', ''),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: expense.isActive
                                            ? AppTheme.textPrimary
                                            : AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Due day ${expense.dueDay}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary.withAlpha((0.7 * 255).toInt()),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                PopupMenuButton(
                                  icon: const Icon(Icons.more_vert, size: 20),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: Text(expense.isActive ? 'Deactivate' : 'Activate'),
                                      onTap: () => _toggleActive(expense),
                                    ),
                                    PopupMenuItem(
                                      child: const Text('Edit'),
                                      onTap: () async {
                                        // Wait for popup to close
                                        await Future.delayed(Duration.zero);
                                        if (context.mounted) {
                                          final result = await Navigator.of(context).push<bool>(
                                            MaterialPageRoute(
                                              builder: (context) => AddFixedExpenseScreen(fixedExpense: expense),
                                            ),
                                          );
                                          if (result == true) _loadData();
                                        }
                                      },
                                    ),
                                    PopupMenuItem(
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onTap: () => _deleteExpense(expense.id!),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }
}
