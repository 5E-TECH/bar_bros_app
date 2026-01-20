import 'package:bar_bros_user/features/barber_shop_services/domain/entities/barber_shop_service.dart';
import 'package:equatable/equatable.dart';

abstract class BarberShopServiceState extends Equatable {
  const BarberShopServiceState();

  @override
  List<Object?> get props => [];
}

class BarberShopServiceInitial extends BarberShopServiceState {}

class BarberShopServiceLoading extends BarberShopServiceState {}

class BarberShopServiceLoaded extends BarberShopServiceState {
  final List<BarberShopService> services;

  const BarberShopServiceLoaded(this.services);

  @override
  List<Object?> get props => [services];
}

class BarberShopServiceError extends BarberShopServiceState {
  final String message;

  const BarberShopServiceError(this.message);

  @override
  List<Object?> get props => [message];
}
