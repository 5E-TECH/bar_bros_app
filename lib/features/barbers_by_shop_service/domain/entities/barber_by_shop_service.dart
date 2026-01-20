import 'package:bar_bros_user/features/barbers_by_shop_service/domain/entities/barber_service_brief.dart';
import 'package:bar_bros_user/features/barbers_by_shop_service/domain/entities/barber_shop_brief.dart';
import 'package:equatable/equatable.dart';

class BarberByShopService extends Equatable {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String username;
  final String bio;
  final String avgReyting;
  final String img;
  final bool isAvailable;
  final List<dynamic> ratings;
  final List<String> barberImages;
  final BarberShopBrief barberShop;
  final List<BarberServiceBrief> services;

  const BarberByShopService({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.username,
    required this.bio,
    required this.avgReyting,
    required this.img,
    required this.isAvailable,
    required this.ratings,
    required this.barberImages,
    required this.barberShop,
    required this.services,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        phoneNumber,
        username,
        bio,
        avgReyting,
        img,
        isAvailable,
        ratings,
        barberImages,
        barberShop,
        services,
      ];
}
