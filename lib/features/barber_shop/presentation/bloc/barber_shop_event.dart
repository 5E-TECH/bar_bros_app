import 'package:bar_bros_user/features/barber_shop/domain/entities/barber_shop_query.dart';
import 'package:equatable/equatable.dart';

abstract class BarberShopEvent extends Equatable {
  const BarberShopEvent();

  @override
  List<Object?> get props => [];
}

class GetBarberShopsEvent extends BarberShopEvent {
  final BarberShopQuery query;

  const GetBarberShopsEvent({this.query = const BarberShopQuery()});

  @override
  List<Object?> get props => [query];
}
