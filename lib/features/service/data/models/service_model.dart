import 'package:bar_bros_user/features/category/data/models/category_model.dart';
import 'package:bar_bros_user/features/service/data/models/barber_shop_service_model.dart';
import 'package:bar_bros_user/features/service/data/models/service_barber_model.dart';
import 'package:bar_bros_user/features/service/domain/entities/service.dart';

class ServiceModel extends Service {
  const ServiceModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.modifiedAt,
    super.createdBy,
    super.modifiedBy,
    required super.isDeleted,
    required super.image,
    required super.serviceImages,
    required super.description,
    required super.name,
    required super.durationMinutes,
    required super.booking,
    required super.barbers,
    required super.category,
    required super.barberShopServices,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final barbersJson = (json['barbers'] as List<dynamic>?) ?? const [];
    final servicesJson =
        (json['barberShopServices'] as List<dynamic>?) ?? const [];
    final imagesJson =
        (json['serviceImages'] as List<dynamic>?) ?? const [];

    return ServiceModel(
      id: json['id'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      modifiedAt: json['modified_at'] as String,
      createdBy: json['created_by'] as String?,
      modifiedBy: json['modified_by'] as String?,
      isDeleted: json['is_deleted'] as bool? ?? false,
      image: json['image'] as String? ?? '',
      serviceImages: imagesJson
          .map((item) =>
              (item as Map<String, dynamic>)['image'] as String? ?? '')
          .where((value) => value.isNotEmpty)
          .toList(),
      description: json['description'] as String? ?? '',
      name: json['name'] as String? ?? '',
      durationMinutes: _asInt(json['duration_minutes']),
      booking: (json['booking'] as List<dynamic>?) ?? const [],
      barbers: barbersJson
          .map((item) => ServiceBarberModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      barberShopServices: servicesJson
          .map((item) =>
              BarberShopServiceModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
