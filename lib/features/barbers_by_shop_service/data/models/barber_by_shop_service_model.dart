import 'package:bar_bros_user/features/barbers_by_shop_service/data/models/barber_service_brief_model.dart';
import 'package:bar_bros_user/features/barbers_by_shop_service/data/models/barber_shop_brief_model.dart';
import 'package:bar_bros_user/features/barbers_by_shop_service/domain/entities/barber_by_shop_service.dart';

class BarberByShopServiceModel extends BarberByShopService {
  const BarberByShopServiceModel({
    required super.id,
    required super.fullName,
    required super.phoneNumber,
    required super.username,
    required super.bio,
    required super.avgReyting,
    required super.img,
    required super.isAvailable,
    required super.ratings,
    required super.barberImages,
    required super.barberShop,
    required super.services,
  });

  factory BarberByShopServiceModel.fromJson(Map<String, dynamic> json) {
    final ratingsJson = (json['reyting'] as List<dynamic>?) ?? const [];
    final imagesJson = (json['barberImage'] as List<dynamic>?) ?? const [];
    final servicesJson = (json['service'] as List<dynamic>?) ?? const [];

    return BarberByShopServiceModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      username: json['username'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      avgReyting: json['avg_reyting']?.toString() ?? '0',
      img: json['img'] as String? ?? '',
      isAvailable: json['is_avaylbl'] as bool? ?? false,
      ratings: ratingsJson,
      barberImages: imagesJson
          .map((item) => item?.toString() ?? '')
          .where((item) => item.isNotEmpty)
          .toList(),
      barberShop: BarberShopBriefModel.fromJson(
        json['barberShop'] as Map<String, dynamic>? ?? const {},
      ),
      services: servicesJson
          .map((item) =>
              BarberServiceBriefModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
