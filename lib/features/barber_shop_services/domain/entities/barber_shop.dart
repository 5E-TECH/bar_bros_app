import 'package:equatable/equatable.dart';

class BarberShop extends Equatable {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String modifiedAt;
  final String? createdBy;
  final String? modifiedBy;
  final bool isDeleted;
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final String img;
  final String description;
  final String phoneNumber;
  final String? username;
  final String? role;
  final String status;
  final String avgRating;

  const BarberShop({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.modifiedAt,
    this.createdBy,
    this.modifiedBy,
    required this.isDeleted,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.img,
    required this.description,
    required this.phoneNumber,
    this.username,
    this.role,
    required this.status,
    required this.avgRating,
  });

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        modifiedAt,
        createdBy,
        modifiedBy,
        isDeleted,
        name,
        location,
        latitude,
        longitude,
        img,
        description,
        phoneNumber,
        username,
        role,
        status,
        avgRating,
      ];
}
