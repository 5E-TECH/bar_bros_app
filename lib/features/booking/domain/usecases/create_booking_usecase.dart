import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/booking/domain/entities/booking.dart';
import 'package:bar_bros_user/features/booking/domain/repositories/booking_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

class CreateBookingParams extends Equatable {
  final int serviceId;
  final int barberId;
  final int barberShopId;
  final String date;
  final String time;
  final String paymentModel;
  final String orderType;

  const CreateBookingParams({
    required this.serviceId,
    required this.barberId,
    required this.barberShopId,
    required this.date,
    required this.time,
    required this.paymentModel,
    required this.orderType,
  });

  @override
  List<Object?> get props => [
        serviceId,
        barberId,
        barberShopId,
        date,
        time,
        paymentModel,
        orderType,
      ];
}

@lazySingleton
class CreateBookingUseCase implements UseCase<Booking, CreateBookingParams> {
  final BookingRepository _repository;

  CreateBookingUseCase(this._repository);

  @override
  Future<Either<Failure, Booking>> call(CreateBookingParams params) async {
    if (params.date.isEmpty) {
      return const Left(ValidationFailure("Sanani tanlang"));
    }

    if (params.time.isEmpty) {
      return const Left(ValidationFailure("Vaqtni tanlang"));
    }

    return await _repository.createBooking(
      serviceId: params.serviceId,
      barberId: params.barberId,
      barberShopId: params.barberShopId,
      date: params.date,
      time: params.time,
      paymentModel: params.paymentModel,
      orderType: params.orderType,
    );
  }
}