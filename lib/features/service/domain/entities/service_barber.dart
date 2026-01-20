import 'package:equatable/equatable.dart';

class ServiceBarber extends Equatable {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String modifiedAt;
  final String? createdBy;
  final String? modifiedBy;
  final bool isDeleted;
  final String fullName;
  final String phoneNumber;
  final String? username;
  final String? bio;
  final String? role;
  final String avgRating;
  final String img;
  final bool isAvailable;

  const ServiceBarber({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.modifiedAt,
    this.createdBy,
    this.modifiedBy,
    required this.isDeleted,
    required this.fullName,
    required this.phoneNumber,
    this.username,
    this.bio,
    this.role,
    required this.avgRating,
    required this.img,
    required this.isAvailable,
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
        fullName,
        phoneNumber,
        username,
        bio,
        role,
        avgRating,
        img,
        isAvailable,
      ];
}
