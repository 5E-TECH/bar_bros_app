import 'package:bar_bros_user/features/user_booking/domain/entities/user_booking_barber.dart';
import 'package:bar_bros_user/features/user_booking/domain/entities/user_booking_barber_shop.dart';
import 'package:bar_bros_user/features/user_booking/domain/entities/user_booking_service.dart';
import 'package:bar_bros_user/features/user_booking/domain/entities/user_booking_user.dart';
import 'package:equatable/equatable.dart';

class UserBooking extends Equatable {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String modifiedAt;
  final String? createdBy;
  final String? modifiedBy;
  final bool isDeleted;
  final String userId;
  final String serviceId;
  final String barberShopId;
  final String barberId;
  final String date;
  final String time;
  final bool reminderSent;
  final String paymentStatus;
  final String status;
  final String paymentModel;
  final String orderType;
  final UserBookingUser user;
  final UserBookingService service;
  final UserBookingBarberShop barberShop;
  final UserBookingBarber barber;

  const UserBooking({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.modifiedAt,
    this.createdBy,
    this.modifiedBy,
    required this.isDeleted,
    required this.userId,
    required this.serviceId,
    required this.barberShopId,
    required this.barberId,
    required this.date,
    required this.time,
    required this.reminderSent,
    required this.paymentStatus,
    required this.status,
    required this.paymentModel,
    required this.orderType,
    required this.user,
    required this.service,
    required this.barberShop,
    required this.barber,
  });

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        modifiedAt,
        createdBy,
        modifiedBy,
        isDeleted,
        userId,
        serviceId,
        barberShopId,
        barberId,
        date,
        time,
        reminderSent,
        paymentStatus,
        status,
        paymentModel,
        orderType,
        user,
        service,
        barberShop,
        barber,
      ];
}
