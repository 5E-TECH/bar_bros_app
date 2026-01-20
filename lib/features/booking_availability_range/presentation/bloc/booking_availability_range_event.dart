import 'package:bar_bros_user/features/booking_availability_range/domain/entities/booking_availability_range_query.dart';
import 'package:equatable/equatable.dart';

abstract class BookingAvailabilityRangeEvent extends Equatable {
  const BookingAvailabilityRangeEvent();

  @override
  List<Object?> get props => [];
}

class GetBookingAvailabilityRangeEvent extends BookingAvailabilityRangeEvent {
  final BookingAvailabilityRangeQuery query;

  const GetBookingAvailabilityRangeEvent(this.query);

  @override
  List<Object?> get props => [query];
}
