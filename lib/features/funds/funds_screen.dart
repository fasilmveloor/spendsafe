import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/db/database_helper.dart';
import '../../core/models/fund.dart';
import '../../core/services/money_calculation_service.dart';
import '../../shared/theme/app_theme.dart';
import 'create_fund_screen.dart';

/// Funds screen
/// Displays all sinking funds with progress toward targets
class FundsScreen extends StatefulWidget {
  const FundsScreen({super.key});

  @override
  State<FundsScreen> createState() => _FundsScreenState();
}

class _FundsScreenState extends State<FundsScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final MoneyCalculationService _moneyService = MoneyCalculationService();
  
  List<Fund> _funds = [];
  Map<int, double> _fundBalances = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load funds
    final fundMaps = await _db.query(
      'funds',
      where: 'is_active = 1',
      orderBy: 'created_at DESC',
    );
    final funds = fundMaps.map((m) => Fund.fromMap(m)).toList();
    
    // Load balance for each fund
    final balances = <int, double>{};
    for (final fund in funds) {
      final balance = await _moneyService.getFundBalance(fund.id!);
      balances[fund.id!] = balance;
    }
    
    setState(() {
      _funds = funds;
      _fundBalances = balances;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Funds'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => const CreateFundScreen(),
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
              child: _funds.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.savings_outlined,
                            size: 64,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No funds yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create funds to save for future goals',
                            style: TextStyle(
                              color: AppTheme.textSecondary.withAlpha((0.8 * 255).toInt()),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        // Info card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                            border: Border.all(color: Colors.green.shade100),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Funds reduce your Available to Spend immediately when you contribute',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green.shade900,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Funds list
                        ..._funds.map((fund) {
                          final balance = _fundBalances[fund.id] ?? 0.0;
                          final target = fund.targetAmount;
                          final hasTarget = target > 0;
                          final percentage = hasTarget ? (balance / target) * 100 : 0.0;
                          final isComplete = percentage >= 100;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () async {
                                final result = await Navigator.of(context).push<bool>(
                                  MaterialPageRoute(
                                    builder: (context) => CreateFundScreen(fund: fund),
                                  ),
                                );
                                if (result == true) _loadData();
                              },
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                  border: Border.all(
                                    color: isComplete
                                        ? Colors.green.shade200
                                        : Colors.grey.shade100,
                                    width: isComplete ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Icon
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: isComplete
                                                ? Colors.green.shade50
                                                : Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                          ),
                                          child: Icon(
                                            _getFundIcon(fund.label),
                                            size: 24,
                                            color: isComplete
                                                ? Colors.green.shade700
                                                : AppTheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        
                                        // Name and details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                fund.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade100,
                                                      borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                                                    ),
                                                    child: Text(
                                                      fund.label.displayName,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppTheme.textSecondary.withAlpha((0.8 * 255).toInt()),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    fund.storageType.displayName,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: AppTheme.textSecondary.withAlpha((0.7 * 255).toInt()),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        // Completion badge
                                        if (isComplete)
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Balance and target
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Current Balance',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.textSecondary.withAlpha((0.7 * 255).toInt()),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              currencyFormat.format(balance).replaceAll('.00', ''),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (hasTarget)
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Target',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: AppTheme.textSecondary.withAlpha((0.7 * 255).toInt()),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                currencyFormat.format(target).replaceAll('.00', ''),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.textSecondary.withAlpha((0.8 * 255).toInt()),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    
                                    // Progress bar
                                    if (hasTarget) ...[
                                      const SizedBox(height: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                        child: LinearProgressIndicator(
                                          value: (percentage / 100).clamp(0.0, 1.0),
                                          backgroundColor: Colors.grey.shade100,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            isComplete ? Colors.green : AppTheme.primary,
                                          ),
                                          minHeight: 8,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${percentage.toStringAsFixed(1)}% of target',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isComplete
                                              ? Colors.green.shade700
                                              : AppTheme.textSecondary.withAlpha((0.8 * 255).toInt()),
                                        ),
                                      ),
                                    ],
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

  IconData _getFundIcon(FundLabel label) {
    switch (label) {
      case FundLabel.emergency:
        return Icons.health_and_safety;
      case FundLabel.goal:
        return Icons.flag;
      case FundLabel.buffer:
        return Icons.security;
      default:
        return Icons.savings;
    }
  }
}
