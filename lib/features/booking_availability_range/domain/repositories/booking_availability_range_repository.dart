import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/features/booking_availability_range/domain/entities/booking_availability_range.dart';
import 'package:bar_bros_user/features/booking_availability_range/domain/entities/booking_availability_range_query.dart';
import 'package:dartz/dartz.dart';

abstract class BookingAvailabilityRangeRepository {
  Future<Either<Failure, BookingAvailabilityRange>> getAvailabilityRange(
    BookingAvailabilityRangeQuery query,
  );
}
