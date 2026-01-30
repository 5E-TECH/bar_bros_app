import 'package:bar_bros_user/features/booking_availability/domain/usecases/get_booking_availability_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'booking_availability_event.dart';
import 'booking_availability_state.dart';

@injectable
class BookingAvailabilityBloc
    extends Bloc<BookingAvailabilityEvent, BookingAvailabilityState> {
  final GetBookingAvailabilityUseCase _getAvailabilityUseCase;

  BookingAvailabilityBloc(this._getAvailabilityUseCase)
      : super(BookingAvailabilityInitial()) {
    on<GetBookingAvailabilityEvent>(_onGetAvailability);
  }

  Future<void> _onGetAvailability(
    GetBookingAvailabilityEvent event,
    Emitter<BookingAvailabilityState> emit,
  ) async {
    emit(BookingAvailabilityLoading());
    final result = await _getAvailabilityUseCase(event.query);
    result.fold(
      (failure) => emit(BookingAvailabilityError(failure.message)),
      (availability) => emit(BookingAvailabilityLoaded(availability)),
    );
  }
}
