import "package:bar_bros_user/core/constants/api_constants.dart";
import "package:bar_bros_user/core/error/errors_server_exceptions.dart";
import "package:bar_bros_user/core/error/exceptions.dart";
import 'package:bar_bros_user/features/auth/data/models/account_model.dart';
import "package:bar_bros_user/features/auth/data/models/register_response_model.dart";
import "package:bar_bros_user/features/auth/data/models/set_fullname_response_model.dart";
import "package:bar_bros_user/features/auth/data/models/verify_response_model.dart";
import "package:dio/dio.dart";
import "package:injectable/injectable.dart";



abstract class AuthRemoteDataSource {
  Future<RegisterResponseModel> register(String phoneNumber);
  Future<VerifyResponseModel> verifyCode(
    String phoneNumber,
    String code, {
    String? token,
  });
  Future<SetFullNameResponseModel> setFullName(String fullName, String token);
  Future<AccountModel> getMyAccount(String token);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<RegisterResponseModel> register(String phoneNumber) async {
    try {
      final response = await _dio.post(
        Constants.registerUser,
        data: {'phone_number': phoneNumber},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        final headerToken = _extractBearerToken(response);
        return RegisterResponseModel.fromJson(
          data,
          verificationToken: headerToken,
        );
      } else {
        throw ServerException(CustomExceptionsText.failed);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ServerException(CustomExceptionsText.invalid);
      }
      throw NetworkException(e.message ?? CustomExceptionsText.network);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VerifyResponseModel> verifyCode(
    String phoneNumber,
    String code, {
    String? token,
  }) async {
    try {
      final response = await _dio.post(
        Constants.verifyCode,
        data: {
          'phone_number': phoneNumber,
          'code': code,
        },
        options: token == null
            ? null
            : Options(
                headers: {'Authorization': 'Bearer $token'},
              ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return VerifyResponseModel.fromJson(response.data);
      } else {
        throw ServerException(CustomExceptionsText.failed);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw ServerException(CustomExceptionsText.wrongCode);
      }
      throw NetworkException(e.message ?? CustomExceptionsText.network);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  String? _extractBearerToken(Response response) {
    final raw = response.headers.value('authorization') ??
        response.headers.value('Authorization');
    if (raw == null || raw.isEmpty) return null;
    if (raw.toLowerCase().startsWith('bearer ')) {
      return raw.substring(7).trim();
    }
    return raw.trim();
  }

  @override
  Future<SetFullNameResponseModel> setFullName(String fullName, String token) async {
    try {
      final response = await _dio.patch(
        Constants.setFullName,
        data: {'full_name': fullName},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SetFullNameResponseModel.fromJson(response.data);
      } else {
        throw ServerException(CustomExceptionsText.failed);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ServerException(CustomExceptionsText.unauthorized);
      }
      throw NetworkException(e.message ?? CustomExceptionsText.network);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AccountModel> getMyAccount(String token) async {
    try {
      final response = await _dio.get(
        Constants.getMyAccount,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return AccountModel.fromJson(response.data['data']);
      } else {
        throw ServerException(CustomExceptionsText.failed);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ServerException(CustomExceptionsText.unauthorized);
      }
      throw NetworkException(e.message ?? CustomExceptionsText.network);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
