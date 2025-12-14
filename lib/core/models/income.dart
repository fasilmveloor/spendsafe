/// Income record model
class Income {
  final int? id;
  final int? sourceId;
  final int accountId;
  final double amount;
  final DateTime receivedDate;
  final String? note;
  final DateTime createdAt;

  Income({
    this.id,
    this.sourceId,
    required this.accountId,
    required this.amount,
    required this.receivedDate,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'source_id': sourceId,
      'account_id': accountId,
      'amount': amount,
      'received_date': receivedDate.millisecondsSinceEpoch,
      'note': note,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'] as int?,
      sourceId: map['source_id'] as int?,
      accountId: map['account_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      receivedDate: DateTime.fromMillisecondsSinceEpoch(map['received_date'] as int),
      note: map['note'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Income copyWith({
    int? id,
    int? sourceId,
    int? accountId,
    double? amount,
    DateTime? receivedDate,
    String? note,
    DateTime? createdAt,
  }) {
    return Income(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      receivedDate: receivedDate ?? this.receivedDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
