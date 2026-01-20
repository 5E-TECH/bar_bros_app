import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/features/booking_availability/domain/entities/booking_availability.dart';
import 'package:bar_bros_user/features/booking_availability/domain/entities/booking_availability_query.dart';
import 'package:dartz/dartz.dart';

abstract class BookingAvailabilityRepository {
  Future<Either<Failure, BookingAvailability>> getAvailability(
    BookingAvailabilityQuery query,
  );
}
