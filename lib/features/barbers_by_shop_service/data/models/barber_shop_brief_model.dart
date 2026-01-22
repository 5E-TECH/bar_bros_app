import 'package:bar_bros_user/features/barbers_by_shop_service/domain/entities/barber_shop_brief.dart';

class BarberShopBriefModel extends BarberShopBrief {
  const BarberShopBriefModel({
    required super.id,
    required super.name,
    required super.location,
    required super.latitude,
    required super.longitude,
    required super.img,
    required super.description,
    required super.phoneNumber,
    required super.status,
    required super.avgRating,
  });

  factory BarberShopBriefModel.fromJson(Map<String, dynamic> json) {
    return BarberShopBriefModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      img: json['img'] as String? ?? '',
      description: json['description'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      status: json['status'] as String? ?? '',
      avgRating: json['avg_rating']?.toString() ?? '0',
    );
  }

  static double _asDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
