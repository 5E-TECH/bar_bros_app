import 'package:equatable/equatable.dart';

class BarberShopService extends Equatable {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String modifiedAt;
  final String? createdBy;
  final String? modifiedBy;
  final bool isDeleted;
  final String barberShopId;
  final String serviceId;
  final int price;

  const BarberShopService({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.modifiedAt,
    this.createdBy,
    this.modifiedBy,
    required this.isDeleted,
    required this.barberShopId,
    required this.serviceId,
    required this.price,
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
        barberShopId,
        serviceId,
        price,
      ];
}
