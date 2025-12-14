/// Fund contribution model (monthly contributions to funds)
class FundContribution {
  final int? id;
  final int fundId;
  final double amount;
  final int month; // YYYYMM format
  final DateTime createdAt;

  FundContribution({
    this.id,
    required this.fundId,
    required this.amount,
    required this.month,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fund_id': fundId,
      'amount': amount,
      'month': month,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory FundContribution.fromMap(Map<String, dynamic> map) {
    return FundContribution(
      id: map['id'] as int?,
      fundId: map['fund_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      month: map['month'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  /// Get DateTime from month (YYYYMM)
  DateTime get monthDate {
    final year = month ~/ 100;
    final monthNum = month % 100;
    return DateTime(year, monthNum);
  }

  /// Create month int from DateTime (YYYYMM format)
  static int monthFromDate(DateTime date) {
    return date.year * 100 + date.month;
  }

  FundContribution copyWith({
    int? id,
    int? fundId,
    double? amount,
    int? month,
    DateTime? createdAt,
  }) {
    return FundContribution(
      id: id ?? this.id,
      fundId: fundId ?? this.fundId,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
