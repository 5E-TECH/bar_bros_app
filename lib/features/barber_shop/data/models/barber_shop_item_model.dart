import 'package:bar_bros_user/features/barber_shop/domain/entities/barber_shop_item.dart';

class BarberShopItemModel extends BarberShopItem {
  const BarberShopItemModel({
    required super.id,
    required super.isDeleted,
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

  factory BarberShopItemModel.fromJson(Map<String, dynamic> json) {
    final phoneValue =
        json['phoneNumber'] ?? json['phone_number'] ?? json['phone'];
    return BarberShopItemModel(
      id: json['id'] as String? ?? '',
      isDeleted: json['is_deleted'] as bool? ?? false,
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      img: json['img'] as String? ?? '',
      description: json['descripton'] as String? ?? '',
      phoneNumber: phoneValue == null ? '' : phoneValue.toString(),
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
