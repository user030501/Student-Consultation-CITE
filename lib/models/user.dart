class User {
  final String username;
  final String role;
  final String passwordHash;

  User({required this.username, required this.role, required this.passwordHash});

  Map<String, dynamic> toJson() => {
        'username': username,
        'role': role,
        'passwordHash': passwordHash,
      };

  static User fromJson(Map<String, dynamic> json) => User(
        username: json['username'] as String,
        role: json['role'] as String,
        passwordHash: json['passwordHash'] as String,
      );
}
