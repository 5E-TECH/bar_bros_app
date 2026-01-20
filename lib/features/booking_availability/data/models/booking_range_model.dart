import 'package:bar_bros_user/features/booking_availability/domain/entities/booking_range.dart';

class BookingRangeModel extends BookingRange {
  const BookingRangeModel({
    required super.start,
    required super.end,
  });

  factory BookingRangeModel.fromJson(Map<String, dynamic> json) {
    return BookingRangeModel(
      start: json['start']?.toString() ?? '',
      end: json['end']?.toString() ?? '',
    );
  }
}
