import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:bar_bros_user/core/error/errors_server_exceptions.dart';
import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/features/booking/data/models/booking_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class BookingRemoteDataSource {
  Future<BookingModel> createBooking({
    required String token,
    required int serviceId,
    required int barberId,
    required int barberShopId,
    required String date,
    required String time,
    required String paymentModel,
    required String orderType,
  });
}

@LazySingleton(as: BookingRemoteDataSource)
class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio _dio;

  BookingRemoteDataSourceImpl(this._dio);

  @override
  Future<BookingModel> createBooking({
    required String token,
    required int serviceId,
    required int barberId,
    required int barberShopId,
    required String date,
    required String time,
    required String paymentModel,
    required String orderType,
  }) async {
    try {
      final response = await _dio.post(
        Constants.createBooking,
        data: {
          'service_id': serviceId,
          'barber_id': barberId,
          'barber_shop_id': barberShopId,
          'date': date,
          'time': time,
          'payment_model': paymentModel,
          'order_type': orderType,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return BookingModel.fromJson(response.data);
      } else {
        throw ServerException(CustomExceptionsText.bookingFailed);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ServerException(CustomExceptionsText.unauthorized);
      }
      if (e.response?.statusCode == 400) {
        throw ServerException(CustomExceptionsText.bookingFailed);
      }
      throw NetworkException(e.message ?? CustomExceptionsText.network);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(e.toString());
    }
  }
}