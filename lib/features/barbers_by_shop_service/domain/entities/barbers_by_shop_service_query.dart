import 'package:equatable/equatable.dart';

class BarbersByShopServiceQuery extends Equatable {
  final String barberShopId;
  final String serviceId;

  const BarbersByShopServiceQuery({
    required this.barberShopId,
    required this.serviceId,
  });

  @override
  List<Object?> get props => [barberShopId, serviceId];
}
