import 'package:equatable/equatable.dart';

abstract class UserBookingEvent extends Equatable {
  const UserBookingEvent();

  @override
  List<Object?> get props => [];
}

class GetUserBookingsEvent extends UserBookingEvent {
  const GetUserBookingsEvent();
}
