import 'package:bar_bros_user/features/user_booking/domain/entities/user_booking_service.dart';

class UserBookingServiceModel extends UserBookingService {
  const UserBookingServiceModel({
    required super.id,
    required super.name,
    required super.description,
    required super.durationMinutes,
  });

  factory UserBookingServiceModel.fromJson(Map<String, dynamic> json) {
    return UserBookingServiceModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      durationMinutes: _parseInt(json['duration_minutes']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
