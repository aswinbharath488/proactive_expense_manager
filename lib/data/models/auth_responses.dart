class SendOtpResponse {
  const SendOtpResponse({
    required this.status,
    required this.otp,
    required this.userExists,
    this.nickname,
    this.token,
  });

  final String status;
  final String otp;
  final bool userExists;
  final String? nickname;
  final String? token;

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      status: json['status'] as String? ?? '',
      otp: json['otp']?.toString() ?? '',
      userExists: json['user_exists'] == true,
      nickname: json['nickname'] as String?,
      token: json['token'] as String?,
    );
  }
}

class CreateAccountResponse {
  const CreateAccountResponse({required this.status, required this.token});

  final String status;
  final String token;

  factory CreateAccountResponse.fromJson(Map<String, dynamic> json) {
    return CreateAccountResponse(
      status: json['status'] as String? ?? '',
      token: json['token'] as String? ?? '',
    );
  }
}
