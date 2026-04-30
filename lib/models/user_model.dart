// lib/models/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'coach' | 'client'
  final String? coachId; // only for clients
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.coachId,
    required this.createdAt,
  });

  bool get isCoach => role == 'coach';
  bool get isClient => role == 'client';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['\$id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      coachId: map['coach_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      if (coachId != null) 'coach_id': coachId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? coachId,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      coachId: coachId ?? this.coachId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
