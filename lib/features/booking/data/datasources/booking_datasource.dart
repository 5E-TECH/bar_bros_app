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
      final requestData = {
        'service_id': serviceId,
        'barber_id': barberId,
        'barber_shop_id': barberShopId,
        'date': date,
        'time': time,
        'payment_model': paymentModel,
        'order_type': orderType,
      };
      print('Booking request data: $requestData');

      final response = await _dio.post(
        Constants.createBooking,
        data: requestData,
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
        final errorData = e.response?.data;
        print('Booking error 400 response: $errorData');
        String errorMessage = CustomExceptionsText.bookingFailed;
        if (errorData is Map) {
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
        }
        throw ServerException(errorMessage);
      }
      throw NetworkException(e.message ?? CustomExceptionsText.network);
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(e.toString());
    }
  }
}