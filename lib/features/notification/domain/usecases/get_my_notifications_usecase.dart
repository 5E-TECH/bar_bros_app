import 'package:bar_bros_user/core/error/failure.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/notification/domain/entities/notification_item.dart';
import 'package:bar_bros_user/features/notification/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetMyNotificationsUseCase
    implements UseCase<List<NotificationItem>, NoParams> {
  final NotificationRepository _repository;

  GetMyNotificationsUseCase(this._repository);

  @override
  Future<Either<Failure, List<NotificationItem>>> call(NoParams params) async {
    return await _repository.getMyNotifications();
  }
}
