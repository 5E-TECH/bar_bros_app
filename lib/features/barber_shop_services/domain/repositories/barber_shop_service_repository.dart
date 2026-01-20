import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/features/barber_shop_services/domain/entities/barber_shop_service.dart';
import 'package:bar_bros_user/features/barber_shop_services/domain/entities/barber_shop_service_query.dart';
import 'package:dartz/dartz.dart';

abstract class BarberShopServiceRepository {
  Future<Either<Failure, List<BarberShopService>>> getAllBarberShopServices(
    BarberShopServiceQuery query,
  );
}
