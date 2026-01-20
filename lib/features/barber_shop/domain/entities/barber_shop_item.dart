import 'package:equatable/equatable.dart';

class BarberShopItem extends Equatable {
  final String id;
  final bool isDeleted;
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final String img;
  final String description;
  final String phoneNumber;
  final String status;
  final String avgRating;

  const BarberShopItem({
    required this.id,
    required this.isDeleted,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.img,
    required this.description,
    required this.phoneNumber,
    required this.status,
    required this.avgRating,
  });

  @override
  List<Object?> get props => [
        id,
        isDeleted,
        name,
        location,
        latitude,
        longitude,
        img,
        description,
        phoneNumber,
        status,
        avgRating,
      ];
}
