import 'package:bar_bros_user/features/auth/domain/entities/register_response.dart';

class RegisterResponseModel extends RegisterResponse {
  const RegisterResponseModel({
    required super.isNew,
    required super.message,
    required super.userId,
    super.verificationToken,
  });

  factory RegisterResponseModel.fromJson(
    Map<String, dynamic> json, {
    String? verificationToken,
  }) {
    // Handle nested 'data' structure from API
    final data = json['data'] as Map<String, dynamic>?;
    final token = verificationToken ?? _extractToken(json);
    final rawIsNew = data?['is_new'] ??
        data?['isNew'] ??
        data?['is_new_user'] ??
        data?['isNewUser'] ??
        json['is_new'] ??
        json['isNew'] ??
        json['is_new_user'] ??
        json['isNewUser'];

    return RegisterResponseModel(
      isNew: _asBool(rawIsNew),
      message: (json['message'] ?? 'success') as String,
      userId:
          (data?['user_id'] ?? json['user_id'] ?? data?['id'] ?? '').toString(),
      verificationToken: token,
    );
  }

  static String? _extractToken(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final raw = data?['token'] ??
        data?['accessToken'] ??
        data?['access_token'] ??
        json['token'] ??
        json['accessToken'] ??
        json['access_token'];
    return raw?.toString();
  }

  static bool _asBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase();
    if (text == 'true' || text == '1') return true;
    if (text == 'false' || text == '0') return false;
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      "is_new": isNew,
      "message": message,
      "user_id": userId,
    };
  }
}
