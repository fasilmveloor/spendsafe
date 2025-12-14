/// User model
class User {
  final int? id;
  final String name;
  final String? email;
  final String? avatarUri;
  final String currency;
  final DateTime createdAt;

  User({
    this.id,
    required this.name,
    this.email,
    this.avatarUri,
    this.currency = 'INR',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_uri': avatarUri,
      'currency': currency,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String?,
      avatarUri: map['avatar_uri'] as String?,
      currency: map['currency'] as String? ?? 'INR',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? avatarUri,
    String? currency,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUri: avatarUri ?? this.avatarUri,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
