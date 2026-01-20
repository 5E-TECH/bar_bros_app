import 'package:bar_bros_user/features/barbers_by_shop_service/domain/entities/barber_by_shop_service.dart';
import 'package:equatable/equatable.dart';

abstract class BarbersByShopServiceState extends Equatable {
  const BarbersByShopServiceState();

  @override
  List<Object?> get props => [];
}

class BarbersByShopServiceInitial extends BarbersByShopServiceState {}

class BarbersByShopServiceLoading extends BarbersByShopServiceState {}

class BarbersByShopServiceLoaded extends BarbersByShopServiceState {
  final List<BarberByShopService> barbers;

  const BarbersByShopServiceLoaded(this.barbers);

  @override
  List<Object?> get props => [barbers];
}

class BarbersByShopServiceError extends BarbersByShopServiceState {
  final String message;

  const BarbersByShopServiceError(this.message);

  @override
  List<Object?> get props => [message];
}
