class LoginResponse {
  final String? token;
  final bool needSignup;
  final String? message;

  LoginResponse({
    required this.token,
    required this.needSignup,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      needSignup: json['needSignup'] ?? false,
      message: json['message'],
    );
  }
}
