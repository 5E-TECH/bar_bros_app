import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/features/service/domain/entities/service.dart';
import 'package:dartz/dartz.dart';

abstract class ServiceRepository {
  Future<Either<Failure, List<Service>>> getAllServices();
}
