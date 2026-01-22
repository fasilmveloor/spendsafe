import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/money_calculation_service.dart';
import '../../core/db/database_helper.dart';
import '../../core/models/expense.dart';
import '../../core/models/category.dart';
import '../../shared/theme/app_theme.dart';
import '../../core/services/preferences_service.dart';
import '../../shared/widgets/transaction_card.dart';
import '../expenses/add_expense_screen.dart';
import '../settings/settings_screen.dart';
import '../alerts/alerts_screen.dart';
import '../transactions/search_transaction_screen.dart';
import '../transactions/transaction_detail_screen.dart';

/// Home screen - main dashboard
/// Displays Available to Spend, Safe Pace, and recent transactions
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MoneyCalculationService _moneyService = MoneyCalculationService();

  double _fts = 0.0;
  double _safePace = 0.0;
  List<Map<String, dynamic>> _recentTransactions = [];
  int _unreadAlerts = 0;
  bool _isLoading = true;
  String _userName = 'My Home';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Public method to refresh data from navigation scaffold
  void refreshData() {
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();

    // Load user name from preferences
    final prefs = PreferencesService();
    final userName = await prefs.getUserName();

    final fts = await _moneyService.calculateFreeToSpend(now);
    final safePace = await _moneyService.calculateSafePace(now);

    // Load recent transactions (last 5)
    final db = DatabaseHelper.instance;
    final transactions = await db.rawQuery('''
      SELECT e.*, c.name as category_name, c.icon as category_icon, a.name as account_name
      FROM expenses e
      LEFT JOIN categories c ON e.category_id = c.id
      LEFT JOIN accounts a ON e.account_id = a.id
      ORDER BY e.expense_date DESC
      LIMIT 5
    ''');

    // Load unread alerts count
    final alertsResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM alerts WHERE is_read = 0',
    );
    final unreadAlerts = (alertsResult.first['count'] as int?) ?? 0;

    setState(() {
      _fts = fts;
      _safePace = safePace;
      _recentTransactions = transactions;
      _unreadAlerts = unreadAlerts;
      _userName = userName ?? 'My Home';
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
    final monthFormat = DateFormat('MMMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              _userName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                if (_unreadAlerts > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _unreadAlerts > 9 ? '9+' : '$_unreadAlerts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AlertsScreen()),
              );
              // Refresh to update badge
              _loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchTransactionScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Month indicator
                    Text(
                      monthFormat.format(DateTime.now()).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Available to Spend (hero metric)
                    Text(
                      currencyFormat.format(_fts).replaceAll('.00', ''),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Available to Spend',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Safe pace
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Safe pace: ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          '${currencyFormat.format(_safePace).replaceAll('.00', '')} / day',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Recent transactions placeholder
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'RECENT TRANSACTIONS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary.withOpacity(0.6),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Recent transactions
                    ..._recentTransactions.map((txn) {
                      final expense = Expense.fromMap(txn);
                      final category = Category(
                        id: expense.categoryId,
                        name: txn['category_name'] as String? ?? 'Unknown',
                        icon: txn['category_icon'] as String?,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TransactionDetailScreen(
                                  expense: expense,
                                  category: category,
                                ),
                              ),
                            );
                            if (result == true) {
                              refreshData();
                            }
                          },
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLarge,
                          ),
                          child: TransactionCard(
                            expense: expense,
                            category: category,
                          ),
                        ),
                      );
                    }).toList(),

                    // Show empty state if no transactions
                    if (_recentTransactions.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLarge,
                          ),
                          border: Border.all(color: Colors.grey.shade50),
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
                                'No transactions yet',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tap + to add your first expense',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
