import 'package:bar_bros_user/features/auth/domain/entities/verify_response.dart';

class VerifyResponseModel extends VerifyResponse {
  const VerifyResponseModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory VerifyResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle nested 'data' structure from API
    final data = json['data'] as Map<String, dynamic>?;
    final access = data?['accessToken'] ??
        data?['access_token'] ??
        json['accessToken'] ??
        json['access_token'];
    final refresh = data?['refreshToken'] ??
        data?['refresh_token'] ??
        json['refreshToken'] ??
        json['refresh_token'];

    return VerifyResponseModel(
      accessToken: access?.toString() ?? '',
      refreshToken: refresh?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {"accessToken": accessToken, "refreshToken": refreshToken};
  }
}
