import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:bar_bros_user/core/error/errors_server_exceptions.dart';
import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/features/booking_availability_range/data/models/booking_availability_range_model.dart';
import 'package:bar_bros_user/features/booking_availability_range/domain/entities/booking_availability_range_query.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class BookingAvailabilityRangeRemoteDataSource {
  Future<BookingAvailabilityRangeModel> getAvailabilityRange(
    String token,
    BookingAvailabilityRangeQuery query,
  );
}

@LazySingleton(as: BookingAvailabilityRangeRemoteDataSource)
class BookingAvailabilityRangeRemoteDataSourceImpl
    implements BookingAvailabilityRangeRemoteDataSource {
  final Dio _dio;

  BookingAvailabilityRangeRemoteDataSourceImpl(this._dio);

  @override
  Future<BookingAvailabilityRangeModel> getAvailabilityRange(
    String token,
    BookingAvailabilityRangeQuery query,
  ) async {
    try {
      final response = await _dio.get(
        Constants.getBookingAvailabilityRange,
        queryParameters: {
          'barberId': query.barberId,
          'from': query.from,
          'to': query.to,
          'serviceId': query.serviceId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return BookingAvailabilityRangeModel.fromJson(data);
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
