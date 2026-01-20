import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/user_booking/domain/entities/user_booking.dart';
import 'package:bar_bros_user/features/user_booking/domain/repositories/user_booking_repository.dart';
import 'package:dartz/dartz.dart';

class GetUserBookingsUseCase implements UseCase<List<UserBooking>, NoParams> {
  final UserBookingRepository _repository;

  GetUserBookingsUseCase(this._repository);

  @override
  Future<Either<Failure, List<UserBooking>>> call(NoParams params) async {
    return await _repository.getUserBookings();
  }
}
