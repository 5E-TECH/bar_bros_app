import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String modifiedAt;
  final String? createdBy;
  final String? modifiedBy;
  final bool isDeleted;
  final String userId;
  final int serviceId;
  final int barberShopId;
  final int barberId;
  final String date;
  final String time;
  final bool reminderSent;
  final String paymentStatus;
  final String status;
  final String paymentModel;
  final String orderType;

  const Booking({
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
      ];
}
