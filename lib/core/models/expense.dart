/// Expense model
class Expense {
  final int? id;
  final double amount;
  final int categoryId; // Mandatory
  final int accountId; // Mandatory
  final int? fundId; // Optional - expense paid from fund
  final DateTime expenseDate;
  final String? note;
  final bool isAutoDetected;
  final DateTime createdAt;

  Expense({
    this.id,
    required this.amount,
    required this.categoryId,
    required this.accountId,
    this.fundId,
    required this.expenseDate,
    this.note,
    this.isAutoDetected = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category_id': categoryId,
      'account_id': accountId,
      'fund_id': fundId,
      'expense_date': expenseDate.millisecondsSinceEpoch,
      'note': note,
      'is_auto_detected': isAutoDetected ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category_id'] as int,
      accountId: map['account_id'] as int,
      fundId: map['fund_id'] as int?,
      expenseDate: DateTime.fromMillisecondsSinceEpoch(map['expense_date'] as int),
      note: map['note'] as String?,
      isAutoDetected: (map['is_auto_detected'] as int?) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Expense copyWith({
    int? id,
    double? amount,
    int? categoryId,
    int? accountId,
    int? fundId,
    DateTime? expenseDate,
    String? note,
    bool? isAutoDetected,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      fundId: fundId ?? this.fundId,
      expenseDate: expenseDate ?? this.expenseDate,
      note: note ?? this.note,
      isAutoDetected: isAutoDetected ?? this.isAutoDetected,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
