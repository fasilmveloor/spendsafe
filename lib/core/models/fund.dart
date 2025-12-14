/// Fund label enum
enum FundLabel {
  emergency,
  goal,
  buffer,
  other;

  @override
  String toString() => name;

  static FundLabel fromString(String value) {
    return FundLabel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FundLabel.other,
    );
  }

  String get displayName {
    switch (this) {
      case FundLabel.emergency:
        return 'Emergency';
      case FundLabel.goal:
        return 'Goal';
      case FundLabel.buffer:
        return 'Buffer';
      case FundLabel.other:
        return 'Other';
    }
  }
}

/// Fund storage type enum
enum FundStorageType {
  cash,
  fd,   // Fixed Deposit
  mf,   // Mutual Fund
  gold,
  other;

  @override
  String toString() => name;

  static FundStorageType fromString(String value) {
    return FundStorageType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FundStorageType.other,
    );
  }

  String get displayName {
    switch (this) {
      case FundStorageType.cash:
        return 'Cash';
      case FundStorageType.fd:
        return 'Fixed Deposit';
      case FundStorageType.mf:
        return 'Mutual Fund';
      case FundStorageType.gold:
        return 'Gold';
      case FundStorageType.other:
        return 'Other';
    }
  }
}

/// Fund model (sinking funds)
class Fund {
  final int? id;
  final String name;
  final FundLabel label;
  final FundStorageType storageType;
  final double targetAmount;
  final DateTime? targetDate;
  final DateTime createdAt;
  final bool isActive;

  Fund({
    this.id,
    required this.name,
    required this.label,
    required this.storageType,
    this.targetAmount = 0.0,
    this.targetDate,
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'label': label.toString(),
      'storage_type': storageType.toString(),
      'target_amount': targetAmount,
      'target_date': targetDate?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Fund.fromMap(Map<String, dynamic> map) {
    return Fund(
      id: map['id'] as int?,
      name: map['name'] as String,
      label: FundLabel.fromString(map['label'] as String),
      storageType: FundStorageType.fromString(map['storage_type'] as String),
      targetAmount: (map['target_amount'] as num?)?.toDouble() ?? 0.0,
      targetDate: map['target_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['target_date'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      isActive: (map['is_active'] as int?) == 1,
    );
  }

  Fund copyWith({
    int? id,
    String? name,
    FundLabel? label,
    FundStorageType? storageType,
    double? targetAmount,
    DateTime? targetDate,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Fund(
      id: id ?? this.id,
      name: name ?? this.name,
      label: label ?? this.label,
      storageType: storageType ?? this.storageType,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
