class SignupResponse {
  final int userId;
  final int accountId;
  final String? token;

  SignupResponse({
    required this.userId,
    required this.accountId,
    required this.token,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      token: json['token'],
      userId: json['userId'],
      accountId: json['accountId'],
    );
  }
}
