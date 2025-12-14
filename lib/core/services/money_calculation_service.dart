import '../db/database_helper.dart';
import '../models/fund_contribution.dart';

/// Money calculation service
/// Implements the core SpendSafe money engine
/// 
/// **Core Philosophy:**
/// - Cash-flow first, not ledger-first
/// - "Available to Spend" (FTS) is the primary authority
/// - Categories are advisory only (warnings, not blockers)
/// - Funds reserve money for future goals (sinking funds)
class MoneyCalculationService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Calculate Free To Spend (FTS) for a given month
  /// 
  /// **Formula:**
  /// FTS = TotalIncomeReceived - FixedExpenses - FundContributions - VariableExpenses
  /// 
  /// Returns the amount available to spend for the specified month
  Future<double> calculateFreeToSpend(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    
    // Get total income received this month
    final incomeResults = await _db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM income
      WHERE received_date >= ? AND received_date <= ?
    ''', [startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch]);
    
    final totalIncome = (incomeResults.first['total'] as num?)?.toDouble() ?? 0.0;
    
    // Get total active fixed expenses for this month
    final fixedExpenseResults = await _db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM fixed_expenses
      WHERE is_active = 1
    ''');
    
    final totalFixedExpenses = (fixedExpenseResults.first['total'] as num?)?.toDouble() ?? 0.0;
    
    // Get total fund contributions for this month (YYYYMM format)
    final monthInt = FundContribution.monthFromDate(month);
    final fundContributionResults = await _db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM fund_contributions
      WHERE month = ?
    ''', [monthInt]);
    
    final totalFundContributions = (fundContributionResults.first['total'] as num?)?.toDouble() ?? 0.0;
    
    // Get total variable expenses for this month
    final expenseResults = await _db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM expenses
      WHERE expense_date >= ? AND expense_date <= ?
    ''', [startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch]);
    
    final totalExpenses = (expenseResults.first['total'] as num?)?.toDouble() ?? 0.0;
    
    // Calculate FTS
    final fts = totalIncome - totalFixedExpenses - totalFundContributions - totalExpenses;
    
    return fts;
  }

  /// Calculate Safe Daily Pace for a given date
  /// 
  /// **Formula:**
  /// SafePace = FTS / RemainingDaysInMonth
  /// 
  /// Returns the recommended daily spending amount
  Future<double> calculateSafePace(DateTime date) async {
    final fts = await calculateFreeToSpend(date);
    final remainingDays = _getRemainingDaysInMonth(date);
    
    if (remainingDays <= 0) return 0.0;
    
    return fts / remainingDays;
  }

  /// Get total spending for a specific day
  Future<double> getTodaySpending(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final results = await _db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM expenses
      WHERE expense_date >= ? AND expense_date <= ?
    ''', [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);
    
    return (results.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get remaining amount for today based on safe pace
  /// 
  /// Returns: SafePace - TodaySpending
  /// 
  /// Negative value means user has exceeded safe pace for today
  Future<double> getRemainingToday(DateTime date) async {
    final safePace = await calculateSafePace(date);
    final todaySpending = await getTodaySpending(date);
    
    return safePace - todaySpending;
  }

  /// Get total spending for a category in a given month
  Future<double> getCategorySpending(int categoryId, DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    
    final results = await _db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM expenses
      WHERE category_id = ?
      AND expense_date >= ? AND expense_date <= ?
    ''', [categoryId, startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch]);
    
    return (results.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get total contributions for a fund
  Future<double> getFundTotalContributions(int fundId) async {
    final results = await _db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM fund_contributions
      WHERE fund_id = ?
    ''', [fundId]);
    
    return (results.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get total expenses paid from a fund
  Future<double> getFundTotalUsage(int fundId) async {
    final results = await _db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM expenses
      WHERE fund_id = ?
    ''', [fundId]);
    
    return (results.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get current fund balance (contributions - usage)
  Future<double> getFundBalance(int fundId) async {
    final contributions = await getFundTotalContributions(fundId);
    final usage = await getFundTotalUsage(fundId);
    
    return contributions - usage;
  }

  /// Get remaining days in month from given date
  int _getRemainingDaysInMonth(DateTime date) {
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    final remainingDays = lastDayOfMonth.day - date.day + 1;
    
    return remainingDays > 0 ? remainingDays : 0;
  }

  /// Get breakdown of FTS calculation for display purposes
  Future<Map<String, double>> getFtsBreakdown(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    
    // Income
    final incomeResults = await _db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM income
      WHERE received_date >= ? AND received_date <= ?
    ''', [startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch]);
    final totalIncome = (incomeResults.first['total'] as num?)?.toDouble() ?? 0.0;
    
    // Fixed expenses
    final fixedExpenseResults = await _db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM fixed_expenses
      WHERE is_active = 1
    ''');
    final totalFixedExpenses = (fixedExpenseResults.first['total'] as num?)?.toDouble() ?? 0.0;
    
    // Fund contributions
    final monthInt = FundContribution.monthFromDate(month);
    final fundContributionResults = await _db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM fund_contributions
      WHERE month = ?
    ''', [monthInt]);
    final totalFundContributions = (fundContributionResults.first['total'] as num?)?.toDouble() ?? 0.0;
    
    // Variable expenses
    final expenseResults = await _db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM expenses
      WHERE expense_date >= ? AND expense_date <= ?
    ''', [startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch]);
    final totalExpenses = (expenseResults.first['total'] as num?)?.toDouble() ?? 0.0;
    
    final fts = totalIncome - totalFixedExpenses - totalFundContributions - totalExpenses;
    
    return {
      'income': totalIncome,
      'fixedExpenses': totalFixedExpenses,
      'fundContributions': totalFundContributions,
      'variableExpenses': totalExpenses,
      'fts': fts,
    };
  }
}
