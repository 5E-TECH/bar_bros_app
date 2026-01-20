import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/features/barber_shop/domain/entities/barber_shop_item.dart';
import 'package:bar_bros_user/features/barber_shop/domain/entities/barber_shop_query.dart';
import 'package:dartz/dartz.dart';

abstract class BarberShopRepository {
  Future<Either<Failure, List<BarberShopItem>>> getBarberShops(
    BarberShopQuery query,
  );
}
