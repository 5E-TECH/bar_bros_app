import 'package:bar_bros_user/features/booking_availability/domain/entities/booking_availability_query.dart';
import 'package:equatable/equatable.dart';

abstract class BookingAvailabilityEvent extends Equatable {
  const BookingAvailabilityEvent();

  @override
  List<Object?> get props => [];
}

class GetBookingAvailabilityEvent extends BookingAvailabilityEvent {
  final BookingAvailabilityQuery query;

  const GetBookingAvailabilityEvent({required this.query});

  @override
  List<Object?> get props => [query];
}
