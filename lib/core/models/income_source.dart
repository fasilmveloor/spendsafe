/// Income source model
class IncomeSource {
  final int? id;
  final String name;
  final int? accountId;
  final bool isActive;
  final DateTime createdAt;

  IncomeSource({
    this.id,
    required this.name,
    this.accountId,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'account_id': accountId,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory IncomeSource.fromMap(Map<String, dynamic> map) {
    return IncomeSource(
      id: map['id'] as int?,
      name: map['name'] as String,
      accountId: map['account_id'] as int?,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  IncomeSource copyWith({
    int? id,
    String? name,
    int? accountId,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return IncomeSource(
      id: id ?? this.id,
      name: name ?? this.name,
      accountId: accountId ?? this.accountId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
