import 'package:bar_bros_user/features/booking_availability_range/domain/entities/booking_availability_range.dart';
import 'package:equatable/equatable.dart';

abstract class BookingAvailabilityRangeState extends Equatable {
  const BookingAvailabilityRangeState();

  @override
  List<Object?> get props => [];
}

class BookingAvailabilityRangeInitial extends BookingAvailabilityRangeState {}

class BookingAvailabilityRangeLoading extends BookingAvailabilityRangeState {}

class BookingAvailabilityRangeLoaded extends BookingAvailabilityRangeState {
  final BookingAvailabilityRange availability;

  const BookingAvailabilityRangeLoaded(this.availability);

  @override
  List<Object?> get props => [availability];
}

class BookingAvailabilityRangeError extends BookingAvailabilityRangeState {
  final String message;

  const BookingAvailabilityRangeError(this.message);

  @override
  List<Object?> get props => [message];
}
