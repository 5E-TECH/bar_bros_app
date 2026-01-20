import 'package:bar_bros_user/features/user_booking/data/models/user_booking_barber_model.dart';
import 'package:bar_bros_user/features/user_booking/data/models/user_booking_barber_shop_model.dart';
import 'package:bar_bros_user/features/user_booking/data/models/user_booking_service_model.dart';
import 'package:bar_bros_user/features/user_booking/data/models/user_booking_user_model.dart';
import 'package:bar_bros_user/features/user_booking/domain/entities/user_booking.dart';

class UserBookingModel extends UserBooking {
  const UserBookingModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.modifiedAt,
    super.createdBy,
    super.modifiedBy,
    required super.isDeleted,
    required super.userId,
    required super.serviceId,
    required super.barberShopId,
    required super.barberId,
    required super.date,
    required super.time,
    required super.reminderSent,
    required super.paymentStatus,
    required super.status,
    required super.paymentModel,
    required super.orderType,
    required super.user,
    required super.service,
    required super.barberShop,
    required super.barber,
  });

  factory UserBookingModel.fromJson(Map<String, dynamic> json) {
    return UserBookingModel(
      id: (json['id'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
      modifiedAt: (json['modified_at'] ?? '').toString(),
      createdBy: json['created_by']?.toString(),
      modifiedBy: json['modified_by']?.toString(),
      isDeleted: json['is_deleted'] == true,
      userId: (json['user_id'] ?? '').toString(),
      serviceId: (json['service_id'] ?? '').toString(),
      barberShopId: (json['barber_shop_id'] ?? '').toString(),
      barberId: (json['barber_id'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      reminderSent: json['reminder_sent'] == true,
      paymentStatus: (json['payment_status'] ?? 'pending').toString(),
      status: (json['status'] ?? 'pending').toString(),
      paymentModel: (json['payment_model'] ?? 'cash').toString(),
      orderType: (json['order_type'] ?? 'online').toString(),
      user: UserBookingUserModel.fromJson(
        (json['user'] as Map<String, dynamic>?) ?? const {},
      ),
      service: UserBookingServiceModel.fromJson(
        (json['service'] as Map<String, dynamic>?) ?? const {},
      ),
      barberShop: UserBookingBarberShopModel.fromJson(
        (json['barber_shop'] as Map<String, dynamic>?) ?? const {},
      ),
      barber: UserBookingBarberModel.fromJson(
        (json['barber'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}
