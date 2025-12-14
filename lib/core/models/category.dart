/// Category model (advisory budgets)
class Category {
  final int? id;
  final String name;
  final String? icon; // Material icon name
  final double monthlyBudget;
  final double warningThreshold; // 0.0 to 1.0 (default 0.8 = 80%)
  final DateTime createdAt;

  Category({
    this.id,
    required this.name,
    this.icon,
    this.monthlyBudget = 0.0,
    this.warningThreshold = 0.8,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'monthly_budget': monthlyBudget,
      'warning_threshold': warningThreshold,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String?,
      monthlyBudget: (map['monthly_budget'] as num?)?.toDouble() ?? 0.0,
      warningThreshold: (map['warning_threshold'] as num?)?.toDouble() ?? 0.8,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    double? monthlyBudget,
    double? warningThreshold,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      warningThreshold: warningThreshold ?? this.warningThreshold,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if category budget warning should be shown
  bool shouldWarn(double currentSpending) {
    if (monthlyBudget <= 0) return false;
    return currentSpending >= (monthlyBudget * warningThreshold);
  }
}
