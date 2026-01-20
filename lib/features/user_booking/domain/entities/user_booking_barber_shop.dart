import 'package:equatable/equatable.dart';

class UserBookingBarberShop extends Equatable {
  final String id;
  final String name;
  final String location;
  final String img;
  final String phoneNumber;
  final String status;
  final String avgRating;

  const UserBookingBarberShop({
    required this.id,
    required this.name,
    required this.location,
    required this.img,
    required this.phoneNumber,
    required this.status,
    required this.avgRating,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        img,
        phoneNumber,
        status,
        avgRating,
      ];
}
