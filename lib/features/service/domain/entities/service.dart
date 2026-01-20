import 'package:bar_bros_user/features/category/domain/entities/category.dart';
import 'package:bar_bros_user/features/service/domain/entities/barber_shop_service.dart';
import 'package:bar_bros_user/features/service/domain/entities/service_barber.dart';
import 'package:equatable/equatable.dart';

class Service extends Equatable {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String modifiedAt;
  final String? createdBy;
  final String? modifiedBy;
  final bool isDeleted;
  final String image;
  final List<String> serviceImages;
  final String description;
  final String name;
  final int durationMinutes;
  final List<dynamic> booking;
  final List<ServiceBarber> barbers;
  final Category category;
  final List<BarberShopService> barberShopServices;

  const Service({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.modifiedAt,
    this.createdBy,
    this.modifiedBy,
    required this.isDeleted,
    required this.image,
    required this.serviceImages,
    required this.description,
    required this.name,
    required this.durationMinutes,
    required this.booking,
    required this.barbers,
    required this.category,
    required this.barberShopServices,
  });

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        modifiedAt,
        createdBy,
        modifiedBy,
        isDeleted,
        image,
        serviceImages,
        description,
        name,
        durationMinutes,
        booking,
        barbers,
        category,
        barberShopServices,
      ];
}
