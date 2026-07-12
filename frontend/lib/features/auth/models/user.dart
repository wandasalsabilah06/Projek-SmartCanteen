import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'pelanggan',
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'pelanggan',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'avatar_url': avatarUrl,
  };

  String get firstName => name.split(' ').first;
  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [id, name, email, role, avatarUrl];
}
