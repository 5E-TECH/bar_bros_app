part of 'booking_bloc.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingSuccess extends BookingState {
  final String bookingId;
  final String date;
  final String time;
  final String status;
  final String paymentStatus;

  const BookingSuccess({
    required this.bookingId,
    required this.date,
    required this.time,
    required this.status,
    required this.paymentStatus,
  });

  @override
  List<Object> get props => [bookingId, date, time, status, paymentStatus];
}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object> get props => [message];
}