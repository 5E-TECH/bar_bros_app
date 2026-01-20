import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/features/booking/domain/entities/booking.dart';
import 'package:dartz/dartz.dart';

abstract class BookingRepository {
  Future<Either<Failure, Booking>> createBooking({
    required int serviceId,
    required int barberId,
    required int barberShopId,
    required String date,
    required String time,
    required String paymentModel,
    required String orderType,
  });
}