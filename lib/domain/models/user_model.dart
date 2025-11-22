class User {
  final String name;
  final String email;
  final String? password;

  User({
    required this.name,
    required this.email,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      if (password != null) 'password': password,
    };
  }
}
