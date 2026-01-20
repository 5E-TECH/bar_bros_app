import 'package:bar_bros_user/features/booking_availability/domain/entities/booking_availability.dart';
import 'package:equatable/equatable.dart';

abstract class BookingAvailabilityState extends Equatable {
  const BookingAvailabilityState();

  @override
  List<Object?> get props => [];
}

class BookingAvailabilityInitial extends BookingAvailabilityState {}

class BookingAvailabilityLoading extends BookingAvailabilityState {}

class BookingAvailabilityLoaded extends BookingAvailabilityState {
  final BookingAvailability availability;

  const BookingAvailabilityLoaded(this.availability);

  @override
  List<Object?> get props => [availability];
}

class BookingAvailabilityError extends BookingAvailabilityState {
  final String message;

  const BookingAvailabilityError(this.message);

  @override
  List<Object?> get props => [message];
}
