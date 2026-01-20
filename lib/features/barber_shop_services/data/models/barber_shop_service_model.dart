import 'package:bar_bros_user/features/barber_shop_services/domain/entities/barber_shop_service.dart';

class BarberShopServiceModel extends BarberShopService {
  const BarberShopServiceModel({
    required super.barberShopId,
    required super.shopName,
    required super.shopLocation,
    required super.shopImage,
    required super.avgRating,
    required super.price,
    required super.distanceKm,
  });

  factory BarberShopServiceModel.fromJson(Map<String, dynamic> json) {
    return BarberShopServiceModel(
      barberShopId: json['barber_shop_id'] as String? ?? '',
      shopName: json['shop_name'] as String? ?? '',
      shopLocation: json['shop_location'] as String? ?? '',
      shopImage: json['shop_image'] as String? ?? '',
      avgRating: json['avg_rating']?.toString() ?? '0',
      price: _asInt(json['price']),
      distanceKm: _asDouble(json['distance_km']),
    );
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
