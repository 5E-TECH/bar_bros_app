import 'package:bar_bros_user/features/booking_availability/domain/entities/booking_range.dart';
import 'package:equatable/equatable.dart';

class BookingAvailability extends Equatable {
  final String date;
  final List<String> freeSlots;
  final List<String> bookedSlots;
  final List<BookingRange> bookedRanges;

  const BookingAvailability({
    required this.date,
    required this.freeSlots,
    required this.bookedSlots,
    required this.bookedRanges,
  });

  @override
  List<Object?> get props => [
        date,
        freeSlots,
        bookedSlots,
        bookedRanges,
      ];
}
