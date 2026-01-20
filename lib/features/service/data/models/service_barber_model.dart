import 'package:bar_bros_user/features/service/domain/entities/service_barber.dart';

class ServiceBarberModel extends ServiceBarber {
  const ServiceBarberModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.modifiedAt,
    super.createdBy,
    super.modifiedBy,
    required super.isDeleted,
    required super.fullName,
    required super.phoneNumber,
    super.username,
    super.bio,
    super.role,
    required super.avgRating,
    required super.img,
    required super.isAvailable,
  });

  factory ServiceBarberModel.fromJson(Map<String, dynamic> json) {
    return ServiceBarberModel(
      id: json['id'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      modifiedAt: json['modified_at'] as String,
      createdBy: json['created_by'] as String?,
      modifiedBy: json['modified_by'] as String?,
      isDeleted: json['is_deleted'] as bool? ?? false,
      fullName: json['full_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      username: json['username'] as String?,
      bio: json['bio'] as String?,
      role: json['role'] as String?,
      avgRating: json['avg_reyting']?.toString() ?? '0',
      img: json['img'] as String? ?? '',
      isAvailable: json['is_avaylbl'] as bool? ?? false,
    );
  }
}
