import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/features/notification/domain/entities/notification_item.dart';
import 'package:dartz/dartz.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationItem>>> getMyNotifications();
  Future<String?> getBarberNameById(String barberId);
}
