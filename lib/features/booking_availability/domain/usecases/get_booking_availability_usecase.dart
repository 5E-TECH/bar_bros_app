import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/booking_availability/domain/entities/booking_availability.dart';
import 'package:bar_bros_user/features/booking_availability/domain/entities/booking_availability_query.dart';
import 'package:bar_bros_user/features/booking_availability/domain/repositories/booking_availability_repository.dart';
import 'package:dartz/dartz.dart';

class GetBookingAvailabilityUseCase
    implements UseCase<BookingAvailability, BookingAvailabilityQuery> {
  final BookingAvailabilityRepository _repository;

  GetBookingAvailabilityUseCase(this._repository);

  @override
  Future<Either<Failure, BookingAvailability>> call(
    BookingAvailabilityQuery params,
  ) async {
    return await _repository.getAvailability(params);
  }
}
