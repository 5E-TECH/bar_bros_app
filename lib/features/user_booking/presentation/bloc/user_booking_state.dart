import 'package:bar_bros_user/features/user_booking/domain/entities/user_booking.dart';
import 'package:equatable/equatable.dart';

abstract class UserBookingState extends Equatable {
  const UserBookingState();

  @override
  List<Object?> get props => [];
}

class UserBookingInitial extends UserBookingState {}

class UserBookingLoading extends UserBookingState {}

class UserBookingLoaded extends UserBookingState {
  final List<UserBooking> allBookings;
  final List<UserBooking> upcomingBookings;
  final List<UserBooking> historyBookings;

  const UserBookingLoaded({
    required this.allBookings,
    required this.upcomingBookings,
    required this.historyBookings,
  });

  @override
  List<Object?> get props => [
        allBookings,
        upcomingBookings,
        historyBookings,
      ];
}

class UserBookingError extends UserBookingState {
  final String message;

  const UserBookingError(this.message);

  @override
  List<Object?> get props => [message];
}
