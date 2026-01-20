import 'package:equatable/equatable.dart';

class BarberShopServiceQuery extends Equatable {
  final String serviceId;
  final double? distance;
  final int? avgRating;
  final double? radiusKm;
  final double? lat;
  final double? lng;

  const BarberShopServiceQuery({
    required this.serviceId,
    this.distance,
    this.avgRating,
    this.radiusKm,
    this.lat,
    this.lng,
  });

  @override
  List<Object?> get props => [
        serviceId,
        distance,
        avgRating,
        radiusKm,
        lat,
        lng,
      ];
}
