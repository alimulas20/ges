// login_model.dart
class LoginModel {
  final String username;
  final String password;

  LoginModel({required this.username, required this.password});

  Map<String, dynamic> toJson() => {'grant_type': 'password', 'username': username, 'password': password};
}
