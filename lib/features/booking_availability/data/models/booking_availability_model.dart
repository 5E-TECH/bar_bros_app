import 'package:bar_bros_user/features/booking_availability/data/models/booking_range_model.dart';
import 'package:bar_bros_user/features/booking_availability/domain/entities/booking_availability.dart';

class BookingAvailabilityModel extends BookingAvailability {
  const BookingAvailabilityModel({
    required super.date,
    required super.freeSlots,
    required super.bookedSlots,
    required super.bookedRanges,
  });

  factory BookingAvailabilityModel.fromJson(Map<String, dynamic> json) {
    final freeSlotsJson = (json['freeSlots'] as List<dynamic>?) ?? const [];
    final bookedSlotsJson = (json['bookedSlots'] as List<dynamic>?) ?? const [];
    final bookedRangesJson =
        (json['bookedRanges'] as List<dynamic>?) ?? const [];
    return BookingAvailabilityModel(
      date: json['date']?.toString() ?? '',
      freeSlots: freeSlotsJson
          .map((item) => item?.toString() ?? '')
          .where((item) => item.isNotEmpty)
          .toList(),
      bookedSlots: bookedSlotsJson
          .map((item) => item?.toString() ?? '')
          .where((item) => item.isNotEmpty)
          .toList(),
      bookedRanges: bookedRangesJson
          .map((item) =>
              BookingRangeModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
