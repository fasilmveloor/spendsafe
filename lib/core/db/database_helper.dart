import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Database helper for SpendSafe SQLite database
/// Handles database creation, migrations, and CRUD operations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Get database instance (singleton pattern)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('spendsafe.db');
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDB(String filePath) async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final String dbPath = join(appDocumentsDir.path, filePath);

    return await openDatabase(
      dbPath,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Create all tables
  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        avatar_uri TEXT,
        currency TEXT DEFAULT 'INR',
        created_at INTEGER NOT NULL
      )
    ''');

    // Accounts table (bank, cash, wallet, etc.)
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        balance REAL DEFAULT 0,
        include_in_fts INTEGER DEFAULT 1,
        icon INTEGER,
        color INTEGER,
        is_default INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER
      )
    ''');

    // Income sources table
    await db.execute('''
      CREATE TABLE income_sources (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        account_id INTEGER,
        amount REAL DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        FOREIGN KEY (account_id) REFERENCES accounts (id)
      )
    ''');

    // Income records table
    await db.execute('''
      CREATE TABLE income (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source_id INTEGER,
        account_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        received_date INTEGER NOT NULL,
        note TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (source_id) REFERENCES income_sources (id),
        FOREIGN KEY (account_id) REFERENCES accounts (id)
      )
    ''');

    // Categories table (advisory budgets)
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT,
        monthly_budget REAL DEFAULT 0,
        warning_threshold REAL DEFAULT 0.8,
        created_at INTEGER NOT NULL
      )
    ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category_id INTEGER NOT NULL,
        account_id INTEGER NOT NULL,
        fund_id INTEGER,
        expense_date INTEGER NOT NULL,
        note TEXT,
        is_auto_detected INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id),
        FOREIGN KEY (account_id) REFERENCES accounts (id),
        FOREIGN KEY (fund_id) REFERENCES funds (id)
      )
    ''');

    // Funds table (sinking funds)
    await db.execute('''
      CREATE TABLE funds (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        label TEXT NOT NULL,
        storage_type TEXT NOT NULL,
        target_amount REAL DEFAULT 0,
        target_date INTEGER,
        created_at INTEGER NOT NULL,
        is_active INTEGER DEFAULT 1
      )
    ''');

    // Fund contributions table
    await db.execute('''
      CREATE TABLE fund_contributions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fund_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        month INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (fund_id) REFERENCES funds (id)
      )
    ''');

    // Fixed expenses table
    await db.execute('''
      CREATE TABLE fixed_expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        account_id INTEGER NOT NULL,
        due_day INTEGER NOT NULL,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id)
      )
    ''');

    // Debts & Dues table
    await db.execute('''
      CREATE TABLE dues (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        person_name TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        account_id INTEGER,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id)
      )
    ''');

    // Alerts table
    await db.execute('''
      CREATE TABLE alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        message TEXT NOT NULL,
        severity TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        is_read INTEGER DEFAULT 0
      )
    ''');

    // Create indexes for better query performance
    await db.execute(
      'CREATE INDEX idx_expenses_date ON expenses(expense_date)',
    );
    await db.execute(
      'CREATE INDEX idx_expenses_category ON expenses(category_id)',
    );
    await db.execute('CREATE INDEX idx_income_date ON income(received_date)');
    await db.execute('CREATE INDEX idx_alerts_read ON alerts(is_read)');
  }

  /// Handle database upgrades (migrations)
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE accounts ADD COLUMN icon INTEGER');
      await db.execute('ALTER TABLE accounts ADD COLUMN color INTEGER');
      await db.execute(
        'ALTER TABLE accounts ADD COLUMN is_default INTEGER DEFAULT 0',
      );
      await db.execute('ALTER TABLE accounts ADD COLUMN updated_at INTEGER');
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE income_sources ADD COLUMN amount REAL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE income_sources ADD COLUMN updated_at INTEGER',
      );
    }
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  /// Get the database file for backup purposes
  Future<File> getDatabaseFile() async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final String dbPath = join(appDocumentsDir.path, 'spendsafe.db');
    return File(dbPath);
  }

  /// Delete database (for testing/reset)
  Future<void> deleteDB() async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final String dbPath = join(appDocumentsDir.path, 'spendsafe.db');
    await deleteDatabase(dbPath);
    _database = null;
  }

  // ============================================================================
  // CRUD Helper Methods
  // ============================================================================

  /// Generic insert method
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  /// Generic query method
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  /// Generic update method
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  /// Generic delete method
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Raw query method
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Raw execute method
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    await db.execute(sql, arguments);
  }
}
