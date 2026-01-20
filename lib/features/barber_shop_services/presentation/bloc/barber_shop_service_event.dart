import 'package:equatable/equatable.dart';
import 'package:bar_bros_user/features/barber_shop_services/domain/entities/barber_shop_service_query.dart';

abstract class BarberShopServiceEvent extends Equatable {
  const BarberShopServiceEvent();

  @override
  List<Object?> get props => [];
}

class GetAllBarberShopServicesEvent extends BarberShopServiceEvent {
  final BarberShopServiceQuery query;

  const GetAllBarberShopServicesEvent({required this.query});

  @override
  List<Object?> get props => [query];
}
