import 'package:bar_bros_user/features/barber_shop/domain/entities/barber_shop_item.dart';
import 'package:equatable/equatable.dart';

abstract class BarberShopState extends Equatable {
  const BarberShopState();

  @override
  List<Object?> get props => [];
}

class BarberShopInitial extends BarberShopState {}

class BarberShopLoading extends BarberShopState {}

class BarberShopLoaded extends BarberShopState {
  final List<BarberShopItem> shops;

  const BarberShopLoaded(this.shops);

  @override
  List<Object?> get props => [shops];
}

class BarberShopError extends BarberShopState {
  final String message;

  const BarberShopError(this.message);

  @override
  List<Object?> get props => [message];
}
