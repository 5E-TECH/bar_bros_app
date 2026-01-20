import 'package:equatable/equatable.dart';

class BarberShopService extends Equatable {
  final String barberShopId;
  final String shopName;
  final String shopLocation;
  final String shopImage;
  final String avgRating;
  final int price;
  final double distanceKm;

  const BarberShopService({
    required this.barberShopId,
    required this.shopName,
    required this.shopLocation,
    required this.shopImage,
    required this.avgRating,
    required this.price,
    required this.distanceKm,
  });

  @override
  List<Object?> get props => [
        barberShopId,
        shopName,
        shopLocation,
        shopImage,
        avgRating,
        price,
        distanceKm,
      ];
}
