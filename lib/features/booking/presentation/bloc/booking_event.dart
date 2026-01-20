part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object> get props => [];
}

class CreateBookingEvent extends BookingEvent {
  final int serviceId;
  final int barberId;
  final int barberShopId;
  final String date;
  final String time;
  final String paymentModel;
  final String orderType;

  const CreateBookingEvent({
    required this.serviceId,
    required this.barberId,
    required this.barberShopId,
    required this.date,
    required this.time,
    required this.paymentModel,
    required this.orderType,
  });

  @override
  List<Object> get props => [
        serviceId,
        barberId,
        barberShopId,
        date,
        time,
        paymentModel,
        orderType,
      ];
}

class ResetBookingEvent extends BookingEvent {
  const ResetBookingEvent();
}