import 'package:bar_bros_user/features/barber_shop_services/domain/entities/barber_service.dart';

class BarberServiceModel extends BarberService {
  const BarberServiceModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.modifiedAt,
    super.createdBy,
    super.modifiedBy,
    required super.isDeleted,
    required super.description,
    required super.name,
    required super.durationMinutes,
  });

  factory BarberServiceModel.fromJson(Map<String, dynamic> json) {
    return BarberServiceModel(
      id: json['id'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      modifiedAt: json['modified_at'] as String,
      createdBy: json['created_by'] as String?,
      modifiedBy: json['modified_by'] as String?,
      isDeleted: json['is_deleted'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      name: json['name'] as String? ?? '',
      durationMinutes: _asInt(json['duration_minutes']),
    );
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
