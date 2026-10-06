class User {
  final String name;
  final String email;
  final String password; // stored locally for demo
  final String role; // 'user' or 'admin'

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'password': password, 'role': role};
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      password: json['password'] ?? '',
      role: json['role'] ?? 'user',
    );
  }
}
