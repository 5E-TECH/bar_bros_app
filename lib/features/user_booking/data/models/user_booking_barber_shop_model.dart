import 'package:bar_bros_user/features/user_booking/domain/entities/user_booking_barber_shop.dart';

class UserBookingBarberShopModel extends UserBookingBarberShop {
  const UserBookingBarberShopModel({
    required super.id,
    required super.name,
    required super.location,
    required super.img,
    required super.phoneNumber,
    required super.status,
    required super.avgRating,
  });

  factory UserBookingBarberShopModel.fromJson(Map<String, dynamic> json) {
    return UserBookingBarberShopModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      img: (json['img'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      avgRating: (json['avg_rating'] ?? '').toString(),
    );
  }
}
