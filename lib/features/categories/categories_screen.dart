import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/db/database_helper.dart';
import '../../core/models/category.dart';
import '../../core/services/money_calculation_service.dart';
import '../../shared/theme/app_theme.dart';

/// Categories screen
/// Displays all categories with budget status (advisory, not blocking)
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final MoneyCalculationService _moneyService = MoneyCalculationService();
  
  List<Category> _categories = [];
  Map<int, double> _categorySpending = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategoriesData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    
    // Load categories
    final categoryMaps = await _db.query('categories', orderBy: 'name ASC');
    final categories = categoryMaps.map((m) => Category.fromMap(m)).toList();
    
    // Load spending for each category
    final spending = <int, double>{};
    for (final category in categories) {
      final amount = await _moneyService.getCategorySpending(category.id!, now);
      spending[category.id!] = amount;
    }
    
    setState(() {
      _categories = categories;
      _categorySpending = spending;
      _isLoading = false;
    });
  }

  Future<void> _loadCategoriesData() async {
    await _loadData();
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
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to add category screen
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.category_outlined,
                            size: 64,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No categories yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Categories help you track spending patterns',
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
                                  'Category budgets warn you, but never block spending',
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
                        
                        // Categories list
                        ..._categories.map((category) {
                          final spending = _categorySpending[category.id] ?? 0.0;
                          final budget = category.monthlyBudget;
                          final hasbudget = budget > 0;
                          final percentage = hasbudget ? (spending / budget) * 100 : 0.0;
                          final shouldWarn = category.shouldWarn(spending);
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () {
                                // TODO: Navigate to category detail screen
                              },
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                  border: Border.all(
                                    color: shouldWarn && hasbudget
                                        ? AppTheme.alertAmberIcon.withAlpha((0.3 * 255).toInt())
                                        : Colors.grey.shade100,
                                    width: shouldWarn && hasbudget ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Icon
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: shouldWarn && hasbudget
                                                ? AppTheme.alertAmberBg
                                                : Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                          ),
                                          child: Icon(
                                            _getCategoryIcon(category.icon),
                                            size: 20,
                                            color: shouldWarn && hasbudget
                                                ? AppTheme.alertAmberIcon
                                                : AppTheme.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        
                                        // Name and spending
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      category.name,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  if (shouldWarn && hasbudget)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: AppTheme.alertAmberBg,
                                                        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                                                      ),
                                                      child: Text(
                                                        '${percentage.toStringAsFixed(0)}%',
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w700,
                                                          color: AppTheme.alertAmberText,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                hasbudget
                                                    ? '${currencyFormat.format(spending).replaceAll('.00', '')} of ${currencyFormat.format(budget).replaceAll('.00', '')}'
                                                    : '${currencyFormat.format(spending).replaceAll('.00', '')} spent',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: AppTheme.textSecondary.withAlpha((0.8 * 255).toInt()),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    // Progress bar (only if budget exists)
                                    if (hasbudget) ...[
                                      const SizedBox(height: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                        child: LinearProgressIndicator(
                                          value: (percentage / 100).clamp(0.0, 1.0),
                                          backgroundColor: Colors.grey.shade100,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            shouldWarn
                                                ? AppTheme.alertAmberIcon
                                                : AppTheme.primary,
                                          ),
                                          minHeight: 6,
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

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'directions_car':
        return Icons.directions_car;
      case 'restaurant':
        return Icons.restaurant;
      case 'movie':
        return Icons.movie;
      case 'shopping_bag':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }
}
