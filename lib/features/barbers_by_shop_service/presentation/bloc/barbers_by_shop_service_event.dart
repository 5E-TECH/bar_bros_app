import 'package:bar_bros_user/features/barbers_by_shop_service/domain/entities/barbers_by_shop_service_query.dart';
import 'package:equatable/equatable.dart';

abstract class BarbersByShopServiceEvent extends Equatable {
  const BarbersByShopServiceEvent();

  @override
  List<Object?> get props => [];
}

class GetBarbersByShopServiceEvent extends BarbersByShopServiceEvent {
  final BarbersByShopServiceQuery query;

  const GetBarbersByShopServiceEvent({required this.query});

  @override
  List<Object?> get props => [query];
}
