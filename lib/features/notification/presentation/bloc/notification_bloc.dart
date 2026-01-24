import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/notification/domain/repositories/notification_repository.dart';
import 'package:bar_bros_user/features/notification/domain/usecases/get_my_notifications_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'notification_event.dart';
import 'notification_state.dart';

@injectable
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetMyNotificationsUseCase _getMyNotificationsUseCase;
  final NotificationRepository _repository;

  NotificationBloc(this._getMyNotificationsUseCase, this._repository)
      : super(NotificationInitial()) {
    on<GetMyNotificationsEvent>(_onGetMyNotifications);
  }

  Future<void> _onGetMyNotifications(
    GetMyNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final result = await _getMyNotificationsUseCase(NoParams());
    await result.fold(
      (failure) async => emit(NotificationError(failure.message)),
      (items) async {
        // First emit with items, then fetch barber names
        emit(NotificationLoaded(items));

        // Get unique barber IDs
        final barberIds = items
            .where((item) => item.barberId != null && item.barberId!.isNotEmpty)
            .map((item) => item.barberId!)
            .toSet();

        if (barberIds.isEmpty) return;

        // Fetch barber names
        final Map<String, String> barberNames = {};
        for (final barberId in barberIds) {
          final name = await _repository.getBarberNameById(barberId);
          if (name != null && name.isNotEmpty) {
            barberNames[barberId] = name;
          }
        }

        // Emit with barber names
        if (barberNames.isNotEmpty) {
          emit(NotificationLoaded(items, barberNames: barberNames));
        }
      },
    );
  }
}
