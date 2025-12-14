import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/expense.dart';
import '../../core/models/category.dart';
import '../../core/models/account.dart';
import '../theme/app_theme.dart';

/// Transaction card widget for displaying expense in a list
class TransactionCard extends StatelessWidget {
  final Expense expense;
  final Category? category;
  final Account? account;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.expense,
    this.category,
    this.account,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: Colors.grey.shade50),
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Icon(
                _getCategoryIcon(),
                size: 20,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 12),
            
            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.note ?? category?.name ?? 'Expense',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${category?.name ?? 'Unknown'} • ${timeFormat.format(expense.expenseDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary.withAlpha((0.8 * 255).toInt()),
                    ),
                  ),
                ],
              ),
            ),
            
            // Amount
            Text(
              '- ${currencyFormat.format(expense.amount).replaceAll('.00', '')}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    if (category?.icon == null) return Icons.receipt;
    
    switch (category!.icon) {
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
      case 'coffee':
        return Icons.local_cafe;
      default:
        return Icons.receipt;
    }
  }
}
