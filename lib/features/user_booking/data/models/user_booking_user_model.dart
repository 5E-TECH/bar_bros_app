import 'package:bar_bros_user/features/user_booking/domain/entities/user_booking_user.dart';

class UserBookingUserModel extends UserBookingUser {
  const UserBookingUserModel({
    required super.id,
    required super.fullName,
    required super.phoneNumber,
    required super.role,
    required super.avatarImage,
  });

  factory UserBookingUserModel.fromJson(Map<String, dynamic> json) {
    return UserBookingUserModel(
      id: (json['id'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      phoneNumber: (json['phone_number'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      avatarImage: (json['avatar_image'] ?? '').toString(),
    );
  }
}
