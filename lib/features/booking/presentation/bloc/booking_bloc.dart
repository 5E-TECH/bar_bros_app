import 'package:bar_bros_user/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

part 'booking_event.dart';
part 'booking_state.dart';

@injectable
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBookingUseCase _createBookingUseCase;

  BookingBloc(this._createBookingUseCase) : super(BookingInitial()) {
    on<CreateBookingEvent>(_onCreateBooking);
    on<ResetBookingEvent>(_onResetBooking);
  }

  Future<void> _onCreateBooking(
    CreateBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    final result = await _createBookingUseCase(
      CreateBookingParams(
        serviceId: event.serviceId,
        barberId: event.barberId,
        barberShopId: event.barberShopId,
        date: event.date,
        time: event.time,
        paymentModel: event.paymentModel,
        orderType: event.orderType,
      ),
    );

    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (booking) => emit(BookingSuccess(
        bookingId: booking.id,
        date: booking.date,
        time: booking.time,
        status: booking.status,
        paymentStatus: booking.paymentStatus,
      )),
    );
  }

  void _onResetBooking(ResetBookingEvent event, Emitter<BookingState> emit) {
    emit(BookingInitial());
  }
}