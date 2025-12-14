/// Fixed expense model (recurring monthly expenses)
class FixedExpense {
  final int? id;
  final String name;
  final double amount;
  final int accountId;
  final int dueDay; // Day of month (1-31)
  final bool isActive;
  final DateTime createdAt;

  FixedExpense({
    this.id,
    required this.name,
    required this.amount,
    required this.accountId,
    required this.dueDay,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'account_id': accountId,
      'due_day': dueDay,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory FixedExpense.fromMap(Map<String, dynamic> map) {
    return FixedExpense(
      id: map['id'] as int?,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      accountId: map['account_id'] as int,
      dueDay: map['due_day'] as int,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  FixedExpense copyWith({
    int? id,
    String? name,
    double? amount,
    int? accountId,
    int? dueDay,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return FixedExpense(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      dueDay: dueDay ?? this.dueDay,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
