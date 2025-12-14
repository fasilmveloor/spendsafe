import '../models/user.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/income_source.dart';
import '../models/income.dart';
import '../models/expense.dart';
import '../models/fund.dart';
import '../models/fund_contribution.dart';
import '../models/fixed_expense.dart';
import '../models/due.dart';
import 'database_helper.dart';

/// Seed data for testing and development
class SeedData {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Initialize database with seed data
  Future<void> seedDatabase() async {
    // Check if already seeded
    final userCount = await _db.rawQuery('SELECT COUNT(*) as count FROM users');
    if ((userCount.first['count'] as int) > 0) {
      print('Database already seeded');
      return;
    }

    print('Seeding database...');

    // Create default user
    final user = User(
      name: 'My Home',
      email: 'user@spendsafe.com',
      currency: 'INR',
    );
    final userId = await _db.insert('users', user.toMap());
    print('Created user: $userId');

    // Create accounts
    final accounts = [
      Account(name: 'Main Bank', type: AccountType.bank, balance: 50000),
      Account(name: 'Cash', type: AccountType.cash, balance: 5000),
      Account(name: 'Wallet', type: AccountType.wallet, balance: 2000),
    ];
    
    final accountIds = <int>[];
    for (final account in accounts) {
      final id = await _db.insert('accounts', account.toMap());
      accountIds.add(id);
    }
    print('Created ${accountIds.length} accounts');

    // Create income sources
    final incomeSources = [
      IncomeSource(name: 'Salary', accountId: accountIds[0]),
      IncomeSource(name: 'Freelance', accountId: accountIds[1]),
    ];
    
    final sourceIds = <int>[];
    for (final source in incomeSources) {
      final id = await _db.insert('income_sources', source.toMap());
      sourceIds.add(id);
    }
    print('Created ${sourceIds.length} income sources');

    // Create income for current month
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    
    final incomeRecords = [
      Income(
        sourceId: sourceIds[0],
        accountId: accountIds[0],
        amount: 45000,
        receivedDate: firstOfMonth.add(const Duration(days: 4)),
      ),
      Income(
        sourceId: sourceIds[1],
        accountId: accountIds [1],
        amount: 8000,
        receivedDate: firstOfMonth.add(const Duration(days: 10)),
      ),
    ];
    
    for (final income in incomeRecords) {
      await _db.insert('income', income.toMap());
    }
    print('Created ${incomeRecords.length} income records');

    // Create categories
    final categories = [
      Category(name: 'Groceries', icon: 'shopping_cart', monthlyBudget: 8000),
      Category(name: 'Transport', icon: 'directions_car', monthlyBudget: 3000),
      Category(name: 'Food & Drink', icon: 'restaurant', monthlyBudget: 5000),
      Category(name: 'Entertainment', icon: 'movie', monthlyBudget: 2000),
      Category(name: 'Shopping', icon: 'shopping_bag', monthlyBudget: 4000),
    ];
    
    final categoryIds = <int>[];
    for (final category in categories) {
      final id = await _db.insert('categories', category.toMap());
      categoryIds.add(id);
    }
    print('Created ${categoryIds.length} categories');

    // Create funds
    final funds = [
      Fund(
        name: 'Emergency Fund',
        label: FundLabel.emergency,
        storageType: FundStorageType.fd,
        targetAmount: 100000,
        targetDate: DateTime.now().add(const Duration(days: 365)),
      ),
      Fund(
        name: 'Vacation',
        label: FundLabel.goal,
        storageType: FundStorageType.cash,
        targetAmount: 50000,
        targetDate: DateTime(now.year, 12, 25),
      ),
    ];
    
    final fundIds = <int>[];
    for (final fund in funds) {
      final id = await _db.insert('funds', fund.toMap());
      fundIds.add(id);
    }
    print('Created ${fundIds.length} funds');

    // Create fund contributions for current month
    final currentMonthInt = FundContribution.monthFromDate(now);
    final fundContributions = [
      FundContribution(fundId: fundIds[0], amount: 5000, month: currentMonthInt),
      FundContribution(fundId: fundIds[1], amount: 3000, month: currentMonthInt),
    ];
    
    for (final contribution in fundContributions) {
      await _db.insert('fund_contributions', contribution.toMap());
    }
    print('Created ${fundContributions.length} fund contributions');

    // Create fixed expenses
    final fixedExpenses = [
      FixedExpense(
        name: 'Rent',
        amount: 15000,
        accountId: accountIds[0],
        dueDay: 5,
      ),
      FixedExpense(
        name: 'Netflix',
        amount: 500,
        accountId: accountIds[2],
        dueDay: 10,
      ),
    ];
    
    for (final expense in fixedExpenses) {
      await _db.insert('fixed_expenses', expense.toMap());
    }
    print('Created ${fixedExpenses.length} fixed expenses');

    // Create sample expenses
    final today = DateTime.now();
    final expenses = [
      Expense(
        amount: 3240,
        categoryId: categoryIds[0],
        accountId: accountIds[0],
        expenseDate: DateTime(today.year, today.month, today.day, 10, 42),
        note: 'Whole Foods Market',
      ),
      Expense(
        amount: 450,
        categoryId: categoryIds[1],
        accountId: accountIds[1],
        expenseDate: DateTime(today.year, today.month, today.day, 9, 15),
        note: 'Uber Ride',
      ),
      Expense(
        amount: 280,
        categoryId: categoryIds[2],
        accountId: accountIds[2],
        expenseDate: DateTime(today.year, today.month, today.day, 8, 30),
        note: 'Starbucks',
      ),
      Expense(
        amount: 1200,
        categoryId: categoryIds[3],
        accountId: accountIds[0],
        expenseDate: today.subtract(const Duration(days: 1)),
        note: 'Movie tickets',
      ),
      Expense(
        amount: 2500,
        categoryId: categoryIds[4],
        accountId: accountIds[0],
        expenseDate: today.subtract(const Duration(days: 2)),
        note: 'New shoes',
      ),
    ];
    
    for (final expense in expenses) {
      await _db.insert('expenses', expense.toMap());
    }
    print('Created ${expenses.length} expenses');

    // Create dues
    final dues = [
      Due(
        personName: 'John',
        amount: 1000,
        type: DueType.owedToMe,
        status: DueStatus.open,
      ),
      Due(
        personName: 'Sarah',
        amount: 500,
        type: DueType.iOwe,
        status: DueStatus.open,
      ),
    ];
    
    for (final due in dues) {
      await _db.insert('dues', due.toMap());
    }
    print('Created ${dues.length} dues');

    print('Database seeding complete!');
  }

  /// Clear all data from database
  Future<void> clearDatabase() async {
    final tables = [
      'alerts',
      'dues',
      'fixed_expenses',
      'fund_contributions',
      'funds',
      'expenses',
      'categories',
      'income',
      'income_sources',
      'accounts',
      'users',
    ];

    for (final table in tables) {
      await _db.delete(table);
    }

    print('Database cleared');
  }

  /// Reset database (clear and reseed)
  Future<void> resetDatabase() async {
    await clearDatabase();
    await seedDatabase();
  }
}
