import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:bar_bros_user/core/error/errors_server_exceptions.dart';
import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/features/booking_availability/data/models/booking_availability_model.dart';
import 'package:bar_bros_user/features/booking_availability/domain/entities/booking_availability_query.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class BookingAvailabilityRemoteDataSource {
  Future<BookingAvailabilityModel> getAvailability(
    String token,
    BookingAvailabilityQuery query,
  );
}

@LazySingleton(as: BookingAvailabilityRemoteDataSource)
class BookingAvailabilityRemoteDataSourceImpl
    implements BookingAvailabilityRemoteDataSource {
  final Dio _dio;

  BookingAvailabilityRemoteDataSourceImpl(this._dio);

  @override
  Future<BookingAvailabilityModel> getAvailability(
    String token,
    BookingAvailabilityQuery query,
  ) async {
    try {
      final response = await _dio.get(
        Constants.getBookingAvailability,
        queryParameters: {
          'barberId': query.barberId,
          'serviceId': query.serviceId,
          'date': query.date,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return BookingAvailabilityModel.fromJson(data);
      } else {
        throw ServerException(CustomExceptionsText.failed);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw ServerException(CustomExceptionsText.unauthorized);
      }
      throw NetworkException(e.message ?? CustomExceptionsText.network);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
