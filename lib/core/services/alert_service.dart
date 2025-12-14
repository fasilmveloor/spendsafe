import '../db/database_helper.dart';
import '../models/alert.dart';
import '../models/category.dart';
import 'money_calculation_service.dart';

/// Alert generation service
/// Generates system alerts based on spending patterns and budgets
class AlertService {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final MoneyCalculationService _moneyService = MoneyCalculationService();

  /// Generate and save pace alert if user exceeds daily safe pace
  Future<void> checkAndGeneratePaceAlert(DateTime date) async {
    final remainingToday = await _moneyService.getRemainingToday(date);
    
    if (remainingToday < 0) {
      final exceededAmount = (-remainingToday).abs();
      
      final alert = Alert(
        type: AlertType.pace,
        message: 'You exceeded today\'s safe pace by ₹${exceededAmount.toStringAsFixed(0)}. '
                'This reduces available spend for upcoming days.',
        severity: AlertSeverity.warning,
      );
      
      await _saveAlert(alert);
    }
  }

  /// Generate budget warning alerts for categories approaching their limit
  Future<void> checkAndGenerateCategoryAlerts(DateTime month) async {
    // Get all categories
    final categoryMaps = await _db.query('categories');
    
    for (final map in categoryMaps) {
      final category = Category.fromMap(map);
      
      if (category.monthlyBudget <= 0) continue;
      
      final spending = await _moneyService.getCategorySpending(category.id!, month);
      
      if (category.shouldWarn(spending)) {
        final percentage = ((spending / category.monthlyBudget) * 100).toStringAsFixed(0);
        
        final alert = Alert(
          type: AlertType.budget,
          message: 'Category "${category.name}" is at $percentage% of monthly budget '
                  '(₹${spending.toStringAsFixed(0)} / ₹${category.monthlyBudget.toStringAsFixed(0)})',
          severity: spending >= category.monthlyBudget ? AlertSeverity.danger : AlertSeverity.warning,
        );
        
        await _saveAlert(alert);
      }
    }
  }

  /// Generate fund progress alerts
  Future<void> checkAndGenerateFundAlerts() async {
    final fundMaps = await _db.query('funds', where: 'is_active = 1');
    
    for (final map in fundMaps) {
      final fundId = map['id'] as int;
      final fundName = map['name'] as String;
      final targetAmount = (map['target_amount'] as num?)?.toDouble() ?? 0.0;
      
      if (targetAmount <= 0) continue;
      
      final balance = await _moneyService.getFundBalance(fundId);
      final progress = (balance / targetAmount) * 100;
      
      // Alert when fund reaches 100%
      if (progress >= 100 && progress < 105) {  // Small buffer to avoid multiple alerts
        final alert = Alert(
          type: AlertType.fund,
          message: 'Fund "$fundName" has reached its target of ₹${targetAmount.toStringAsFixed(0)}!',
          severity: AlertSeverity.info,
        );
        
        await _saveAlert(alert);
      }
    }
  }

  /// Generate alerts for pending dues
  Future<void> checkAndGenerateDueAlerts() async {
    final dueMaps = await _db.query('dues', where: 'status = ?', whereArgs: ['open']);
    
    for (final map in dueMaps) {
      final personName = map['person_name'] as String;
      final amount = (map['amount'] as num).toDouble();
      final type = map['type'] as String;
      
      String message;
      if (type == 'i_owe') {
        message = 'Pending payment: You owe ₹${amount.toStringAsFixed(0)} to $personName';
      } else {
        message = 'Pending receipt: $personName owes you ₹${amount.toStringAsFixed(0)}';
      }
      
      final alert = Alert(
        type: AlertType.due,
        message: message,
        severity: type == 'i_owe' ? AlertSeverity.warning : AlertSeverity.info,
      );
      
      await _saveAlert(alert);
    }
  }

  /// Save alert to database (avoid duplicates based on message)
  Future<void> _saveAlert(Alert alert) async {
    // Check if similar alert exists (same type and message in last 24 hours)
    final oneDayAgo = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
    
    final existing = await _db.rawQuery('''
      SELECT COUNT(*) as count
      FROM alerts
      WHERE type = ? AND message = ? AND created_at > ?
    ''', [alert.type.toString(), alert.message, oneDayAgo]);
    
    final count = (existing.first['count'] as int?) ?? 0;
    
    if (count == 0) {
      await _db.insert('alerts', alert.toMap());
    }
  }

  /// Get unread alerts count
  Future<int> getUnreadAlertsCount() async {
    final results = await _db.rawQuery('''
      SELECT COUNT(*) as count
      FROM alerts
      WHERE is_read = 0
    ''');
    
    return (results.first['count'] as int?) ?? 0;
  }

  /// Mark alert as read
  Future<void> markAsRead(int alertId) async {
    await _db.update(
      'alerts',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [alertId],
    );
  }

  /// Mark all alerts as read
  Future<void> markAllAsRead() async {
    await _db.update(
      'alerts',
      {'is_read': 1},
      where: 'is_read = 0',
    );
  }

  /// Delete old read alerts (older than 30 days)
  Future<void> cleanupOldAlerts() async {
    final thirtyDaysAgo = DateTime.now()
        .subtract(const Duration(days: 30))
        .millisecondsSinceEpoch;
    
    await _db.delete(
      'alerts',
      where: 'is_read = 1 AND created_at < ?',
      whereArgs: [thirtyDaysAgo],
    );
  }
}
