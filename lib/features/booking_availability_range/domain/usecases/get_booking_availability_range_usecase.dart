import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/booking_availability_range/domain/entities/booking_availability_range.dart';
import 'package:bar_bros_user/features/booking_availability_range/domain/entities/booking_availability_range_query.dart';
import 'package:bar_bros_user/features/booking_availability_range/domain/repositories/booking_availability_range_repository.dart';
import 'package:dartz/dartz.dart';

class GetBookingAvailabilityRangeUseCase
    implements UseCase<BookingAvailabilityRange, BookingAvailabilityRangeQuery> {
  final BookingAvailabilityRangeRepository _repository;

  GetBookingAvailabilityRangeUseCase(this._repository);

  @override
  Future<Either<Failure, BookingAvailabilityRange>> call(
    BookingAvailabilityRangeQuery params,
  ) async {
    return await _repository.getAvailabilityRange(params);
  }
}
