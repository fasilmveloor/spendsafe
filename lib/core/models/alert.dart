/// Alert type enum
enum AlertType {
  pace,
  budget,
  fund,
  due,
  system;

  @override
  String toString() => name;

  static AlertType fromString(String value) {
    return AlertType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AlertType.system,
    );
  }

  String get displayName {
    switch (this) {
      case AlertType.pace:
        return 'Pace Alert';
      case AlertType.budget:
        return 'Budget Alert';
      case AlertType.fund:
        return 'Fund Alert';
      case AlertType.due:
        return 'Due Alert';
      case AlertType.system:
        return 'System Alert';
    }
  }
}

/// Alert severity enum
enum AlertSeverity {
  info,
  warning,
  danger;

  @override
  String toString() => name;

  static AlertSeverity fromString(String value) {
    return AlertSeverity.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AlertSeverity.info,
    );
  }
}

/// Alert model (system-generated alerts)
class Alert {
  final int? id;
  final AlertType type;
  final String message;
  final AlertSeverity severity;
  final DateTime createdAt;
  final bool isRead;

  Alert({
    this.id,
    required this.type,
    required this.message,
    required this.severity,
    DateTime? createdAt,
    this.isRead = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'message': message,
      'severity': severity.toString(),
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_read': isRead ? 1 : 0,
    };
  }

  factory Alert.fromMap(Map<String, dynamic> map) {
    return Alert(
      id: map['id'] as int?,
      type: AlertType.fromString(map['type'] as String),
      message: map['message'] as String,
      severity: AlertSeverity.fromString(map['severity'] as String),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      isRead: (map['is_read'] as int?) == 1,
    );
  }

  Alert copyWith({
    int? id,
    AlertType? type,
    String? message,
    AlertSeverity? severity,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return Alert(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
