import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/user_booking/domain/entities/user_booking.dart';
import 'package:bar_bros_user/features/user_booking/domain/usecases/get_user_bookings_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_booking_event.dart';
import 'user_booking_state.dart';

class UserBookingBloc extends Bloc<UserBookingEvent, UserBookingState> {
  final GetUserBookingsUseCase _getUserBookingsUseCase;

  UserBookingBloc(this._getUserBookingsUseCase)
      : super(UserBookingInitial()) {
    on<GetUserBookingsEvent>(_onGetUserBookings);
  }

  Future<void> _onGetUserBookings(
    GetUserBookingsEvent event,
    Emitter<UserBookingState> emit,
  ) async {
    emit(UserBookingLoading());
    final result = await _getUserBookingsUseCase(NoParams());
    result.fold(
      (failure) => emit(UserBookingError(failure.message)),
      (bookings) {
        final now = DateTime.now();
        final history = <UserBooking>[];
        final upcoming = <UserBooking>[];

        for (final booking in bookings) {
          final status = booking.status.toLowerCase();
          if (status == 'completed' || status == 'cancelled') {
            history.add(booking);
            continue;
          }
          final startTime = _parseBookingDateTime(booking.date, booking.time);
          if (startTime == null) {
            history.add(booking);
            continue;
          }
          final endTime = startTime.add(Duration(minutes: booking.service.durationMinutes));
          final isUpcoming = startTime.isAfter(now);
          final isInProgress = now.isAfter(startTime) && now.isBefore(endTime);
          if (isUpcoming || isInProgress) {
            upcoming.add(booking);
          } else {
            history.add(booking);
          }
        }

        emit(
          UserBookingLoaded(
            allBookings: bookings,
            upcomingBookings: upcoming,
            historyBookings: history,
          ),
        );
      },
    );
  }

  DateTime? _parseBookingDateTime(String date, String time) {
    final normalizedDate = date.trim();
    final normalizedTime = time.trim();
    if (normalizedDate.isEmpty && normalizedTime.isEmpty) return null;
    final looksLikeDateTime = normalizedTime.contains('-') &&
        (normalizedTime.contains('T') || normalizedTime.contains(' '));
    if (looksLikeDateTime) {
      final normalized = normalizedTime.contains(' ')
          ? normalizedTime.replaceFirst(' ', 'T')
          : normalizedTime;
      try {
        return DateTime.parse(normalized);
      } catch (_) {
        return null;
      }
    }
    if (normalizedDate.isEmpty || normalizedTime.isEmpty) return null;
    final formattedTime = normalizedTime.contains('T')
        ? normalizedTime.split('T').last
        : normalizedTime.split(' ').first;
    final value = '${normalizedDate}T${formattedTime}';
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
}
