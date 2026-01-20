import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:bar_bros_user/core/error/errors_server_exceptions.dart';
import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/features/user_booking/data/models/user_booking_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class UserBookingRemoteDataSource {
  Future<List<UserBookingModel>> getUserBookings(String token);
}

@LazySingleton(as: UserBookingRemoteDataSource)
class UserBookingRemoteDataSourceImpl implements UserBookingRemoteDataSource {
  final Dio _dio;

  UserBookingRemoteDataSourceImpl(this._dio);

  @override
  Future<List<UserBookingModel>> getUserBookings(String token) async {
    try {
      final response = await _dio.get(
        Constants.getUserBookings,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .map((item) =>
                UserBookingModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(CustomExceptionsText.failed);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw ServerException(CustomExceptionsText.unauthorized);
      }
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw NetworkException(e.message ?? CustomExceptionsText.network);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
