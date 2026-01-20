import 'package:bar_bros_user/features/booking_availability_range/domain/entities/booking_availability_day.dart';
import 'package:equatable/equatable.dart';

class BookingAvailabilityRange extends Equatable {
  final String from;
  final String to;
  final int totalDays;
  final List<BookingAvailabilityDay> days;

  const BookingAvailabilityRange({
    required this.from,
    required this.to,
    required this.totalDays,
    required this.days,
  });

  @override
  List<Object?> get props => [
        from,
        to,
        totalDays,
        days,
      ];
}
