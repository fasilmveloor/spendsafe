/// Account types enum
enum AccountType {
  bank,
  cash,
  wallet,
  card,
  other;

  @override
  String toString() => name;

  static AccountType fromString(String value) {
    return AccountType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AccountType.other,
    );
  }
}

/// Account model (manual accounts, no bank sync)
class Account {
  final int? id;
  final String name;
  final AccountType type;
  final double balance;
  final bool includeInFts; // Include in Free To Spend calculation
  final int? icon;
  final int? color;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Account({
    this.id,
    required this.name,
    required this.type,
    this.balance = 0.0,
    this.includeInFts = true,
    this.icon,
    this.color,
    this.isDefault = false,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'balance': balance,
      'include_in_fts': includeInFts ? 1 : 0,
      'icon': icon,
      'color': color,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: AccountType.fromString(map['type'] as String),
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      includeInFts: (map['include_in_fts'] as int?) == 1,
      icon: map['icon'] as int?,
      color: map['color'] as int?,
      isDefault: (map['is_default'] as int?) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] != null ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int) : null,
    );
  }

  Account copyWith({
    int? id,
    String? name,
    AccountType? type,
    double? balance,
    bool? includeInFts,
    int? icon,
    int? color,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      includeInFts: includeInFts ?? this.includeInFts,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
