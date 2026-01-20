import 'package:bar_bros_user/features/booking_availability_range/data/models/booking_availability_day_model.dart';
import 'package:bar_bros_user/features/booking_availability_range/domain/entities/booking_availability_range.dart';

class BookingAvailabilityRangeModel extends BookingAvailabilityRange {
  const BookingAvailabilityRangeModel({
    required super.from,
    required super.to,
    required super.totalDays,
    required super.days,
  });

  factory BookingAvailabilityRangeModel.fromJson(Map<String, dynamic> json) {
    final daysJson = (json['days'] as List<dynamic>?) ?? const [];
    return BookingAvailabilityRangeModel(
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      totalDays: json['totalDays'] is int
          ? json['totalDays'] as int
          : int.tryParse(json['totalDays']?.toString() ?? '') ?? 0,
      days: daysJson
          .map((item) => BookingAvailabilityDayModel.fromJson(
              item as Map<String, dynamic>))
          .toList(),
    );
  }
}
