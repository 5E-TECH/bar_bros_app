import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/features/user_booking/domain/entities/user_booking.dart';
import 'package:dartz/dartz.dart';

abstract class UserBookingRepository {
  Future<Either<Failure, List<UserBooking>>> getUserBookings();
}
