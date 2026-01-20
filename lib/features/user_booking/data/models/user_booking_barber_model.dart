import 'package:bar_bros_user/features/user_booking/domain/entities/user_booking_barber.dart';

class UserBookingBarberModel extends UserBookingBarber {
  const UserBookingBarberModel({
    required super.id,
    required super.fullName,
    required super.phoneNumber,
    required super.bio,
    required super.avgReyting,
    required super.img,
    required super.isAvailable,
  });

  factory UserBookingBarberModel.fromJson(Map<String, dynamic> json) {
    return UserBookingBarberModel(
      id: (json['id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      phoneNumber: (json['phone_number'] ?? '').toString(),
      bio: (json['bio'] ?? '').toString(),
      avgReyting: (json['avg_reyting'] ?? '').toString(),
      img: (json['img'] ?? '').toString(),
      isAvailable: json['is_avaylbl'] == true,
    );
  }
}
