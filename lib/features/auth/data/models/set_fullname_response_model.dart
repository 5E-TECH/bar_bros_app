import 'package:bar_bros_user/features/auth/domain/entities/set_fullname_response.dart';

class SetFullNameResponseModel extends SetFullNameResponse {
  const SetFullNameResponseModel({
    required super.message,
    required super.accessToken,
    required super.refreshToken,
  });

  factory SetFullNameResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle nested 'data' structure from API
    final data = json['data'] as Map<String, dynamic>?;

    return SetFullNameResponseModel(
      message: (json['message'] ?? 'success') as String,
      accessToken: (data?['accessToken'] ?? json['accessToken'] ?? '') as String,
      refreshToken: (data?['refreshToken'] ?? json['refreshToken'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "accessToken": accessToken,
      "refreshToken": refreshToken,
    };
  }
}
