import 'package:equatable/equatable.dart';

class BookingAvailabilityDay extends Equatable {
  final String date;
  final List<String> freeSlots;

  const BookingAvailabilityDay({
    required this.date,
    required this.freeSlots,
  });

  @override
  List<Object?> get props => [
        date,
        freeSlots,
      ];
}
