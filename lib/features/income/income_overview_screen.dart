import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/db/database_helper.dart';
import '../../core/models/income.dart';
import '../../core/models/income_source.dart';
import '../../core/models/account.dart';
import '../../shared/theme/app_theme.dart';
import 'add_income_source_screen.dart';
import 'record_income_screen.dart';

/// Income overview screen
/// Displays income sources and recent income records
class IncomeOverviewScreen extends StatefulWidget {
  const IncomeOverviewScreen({super.key});

  @override
  State<IncomeOverviewScreen> createState() => _IncomeOverviewScreenState();
}

class _IncomeOverviewScreenState extends State<IncomeOverviewScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  List<IncomeSource> _sources = [];
  List<Map<String, dynamic>> _recentIncome = [];
  double _monthlyTotal = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load income sources
    final sourceMaps = await _db.query('income_sources', orderBy: 'name ASC');
    final sources = sourceMaps.map((m) => IncomeSource.fromMap(m)).toList();
    
    // Load recent income (this month)
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    final incomeRecords = await _db.rawQuery('''
      SELECT i.*, s.name as source_name, a.name as account_name
      FROM income i
      LEFT JOIN income_sources s ON i.source_id = s.id
      LEFT JOIN accounts a ON i.account_id = a.id
      WHERE i.received_date >= ? AND i.received_date <= ?
      ORDER BY i.received_date DESC
    ''', [startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch]);
    
    // Calculate monthly total
    final totalResult = await _db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM income
      WHERE received_date >= ? AND received_date <= ?
    ''', [startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch]);
    
    final total = (totalResult.first['total'] as num?)?.toDouble() ?? 0.0;
    
    setState(() {
      _sources = sources;
      _recentIncome = incomeRecords;
      _monthlyTotal = total;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income'),
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0066FF), Color(0xFF0052CC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'This Month',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormat.format(_monthlyTotal).replaceAll('.00', ''),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Total Income Received',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Income sources section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Income Sources',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final result = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (context) => const AddIncomeSourceScreen(),
                            ),
                          );
                          if (result == true) _loadData();
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Source'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (_sources.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      child: const Center(
                        child: Text(
                          'No income sources yet',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._sources.map((source) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
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
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: source.isActive
                                      ? Colors.green.shade50
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                ),
                                child: Icon(
                                  Icons.account_balance_wallet,
                                  size: 20,
                                  color: source.isActive
                                      ? Colors.green.shade700
                                      : AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      source.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      source.isActive ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: source.isActive
                                            ? Colors.green.shade700
                                            : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () async {
                                  final result = await Navigator.of(context).push<bool>(
                                    MaterialPageRoute(
                                      builder: (context) => AddIncomeSourceScreen(incomeSource: source),
                                    ),
                                  );
                                  if (result == true) _loadData();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  
                  const SizedBox(height: 32),
                  
                  // Recent income section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Income',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final result = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (context) => const RecordIncomeScreen(),
                            ),
                          );
                          if (result == true) _loadData();
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Record'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (_recentIncome.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      child: const Center(
                        child: Text(
                          'No income recorded this month',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._recentIncome.map((record) {
                      final income = Income.fromMap(record);
                      final sourceName = record['source_name'] as String? ?? 'Unknown';
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
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
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                ),
                                child: Icon(
                                  Icons.arrow_downward,
                                  size: 20,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sourceName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      dateFormat.format(income.receivedDate),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '+ ${currencyFormat.format(income.amount).replaceAll('.00', '')}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
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
