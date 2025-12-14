/// Due type enum (debt or receivable)
enum DueType {
  owedToMe,  // I should receive this
  iOwe;      // I need to pay this

  @override
  String toString() {
    switch (this) {
      case DueType.owedToMe:
        return 'owed_to_me';
      case DueType.iOwe:
        return 'i_owe';
    }
  }

  static DueType fromString(String value) {
    switch (value) {
      case 'owed_to_me':
        return DueType.owedToMe;
      case 'i_owe':
        return DueType.iOwe;
      default:
        return DueType.iOwe;
    }
  }

  String get displayName {
    switch (this) {
      case DueType.owedToMe:
        return 'Owed to Me';
      case DueType.iOwe:
        return 'I Owe';
    }
  }
}

/// Due status enum
enum DueStatus {
  open,
  settled;

  @override
  String toString() => name;

  static DueStatus fromString(String value) {
    return DueStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DueStatus.open,
    );
  }

  String get displayName {
    switch (this) {
      case DueStatus.open:
        return 'Pending';
      case DueStatus.settled:
        return 'Settled';
    }
  }
}

/// Due model (debts and receivables)
class Due {
  final int? id;
  final String personName;
  final double amount;
  final DueType type;
  final DueStatus status;
  final int? accountId;
  final DateTime createdAt;

  Due({
    this.id,
    required this.personName,
    required this.amount,
    required this.type,
    this.status = DueStatus.open,
    this.accountId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'person_name': personName,
      'amount': amount,
      'type': type.toString(),
      'status': status.toString(),
      'account_id': accountId,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Due.fromMap(Map<String, dynamic> map) {
    return Due(
      id: map['id'] as int?,
      personName: map['person_name'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: DueType.fromString(map['type'] as String),
      status: DueStatus.fromString(map['status'] as String),
      accountId: map['account_id'] as int?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Due copyWith({
    int? id,
    String? personName,
    double? amount,
    DueType? type,
    DueStatus? status,
    int? accountId,
    DateTime? createdAt,
  }) {
    return Due(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      accountId: accountId ?? this.accountId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
