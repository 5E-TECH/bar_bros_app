import 'package:bar_bros_user/features/barber_shop_services/domain/entities/barber_shop.dart';

class BarberShopModel extends BarberShop {
  const BarberShopModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.modifiedAt,
    super.createdBy,
    super.modifiedBy,
    required super.isDeleted,
    required super.name,
    required super.location,
    required super.latitude,
    required super.longitude,
    required super.img,
    required super.description,
    required super.phoneNumber,
    super.username,
    super.role,
    required super.status,
    required super.avgRating,
  });

  factory BarberShopModel.fromJson(Map<String, dynamic> json) {
    final phoneValue =
        json['phoneNumber'] ?? json['phone_number'] ?? json['phone'];
    return BarberShopModel(
      id: json['id'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      modifiedAt: json['modified_at'] as String,
      createdBy: json['created_by'] as String?,
      modifiedBy: json['modified_by'] as String?,
      isDeleted: json['is_deleted'] as bool? ?? false,
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      img: json['img'] as String? ?? '',
      description: json['description'] as String? ?? '',
      phoneNumber: phoneValue == null ? '' : phoneValue.toString(),
      username: json['username'] as String?,
      role: json['role'] as String?,
      status: json['status'] as String? ?? '',
      avgRating: json['avg_rating']?.toString() ?? '0',
    );
  }

  static double _asDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
