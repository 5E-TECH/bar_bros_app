import 'package:bar_bros_user/features/booking_availability_range/domain/entities/booking_availability_day.dart';

class BookingAvailabilityDayModel extends BookingAvailabilityDay {
  const BookingAvailabilityDayModel({
    required super.date,
    required super.freeSlots,
  });

  factory BookingAvailabilityDayModel.fromJson(Map<String, dynamic> json) {
    final freeSlotsJson = (json['freeSlots'] as List<dynamic>?) ?? const [];
    return BookingAvailabilityDayModel(
      date: json['date']?.toString() ?? '',
      freeSlots: freeSlotsJson
          .map((item) => item?.toString() ?? '')
          .where((item) => item.isNotEmpty)
          .toList(),
    );
  }
}
