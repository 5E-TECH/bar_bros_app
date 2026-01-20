import 'package:bar_bros_user/features/service/domain/entities/barber_shop_service.dart';

class BarberShopServiceModel extends BarberShopService {
  const BarberShopServiceModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.modifiedAt,
    super.createdBy,
    super.modifiedBy,
    required super.isDeleted,
    required super.barberShopId,
    required super.serviceId,
    required super.price,
  });

  factory BarberShopServiceModel.fromJson(Map<String, dynamic> json) {
    return BarberShopServiceModel(
      id: json['id'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      modifiedAt: json['modified_at'] as String,
      createdBy: json['created_by'] as String?,
      modifiedBy: json['modified_by'] as String?,
      isDeleted: json['is_deleted'] as bool? ?? false,
      barberShopId: json['barber_shop_id'] as String? ?? '',
      serviceId: json['service_id'] as String? ?? '',
      price: _asInt(json['price']),
    );
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
