import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String id;
  final String? email;
  final String? phone;
  final DateTime? emailConfirmedAt;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  UserModel({
    required this.id,
    this.email,
    this.phone,
    this.emailConfirmedAt,
    required this.createdAt,
    this.metadata,
  });

  /// Supabase User'dan UserModel'e çevirme
  factory UserModel.fromSupabaseUser(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      phone: user.phone,
      emailConfirmedAt: user.emailConfirmedAt != null
          ? DateTime.parse(user.emailConfirmedAt!)
          : null,
      createdAt: DateTime.parse(user.createdAt!),
      metadata: user.userMetadata,
    );
  }

  /// Debug için
  @override
  String toString() {
    return 'UserModel(id: $id, email: $email)';
  }

  /// Equality (karşılaştırma için)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}