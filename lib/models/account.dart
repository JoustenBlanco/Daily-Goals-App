class UserAccount {
  final String email;
  final String accessToken;
  final String? refreshToken;

  UserAccount({
    required this.email,
    required this.accessToken,
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
        email: json['email'],
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken'],
      );
}
