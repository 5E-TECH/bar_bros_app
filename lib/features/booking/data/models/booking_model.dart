import 'package:bar_bros_user/features/booking/domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
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
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return BookingModel(
      id: (data['id'] ?? '').toString(),
      createdAt: (data['created_at'] ?? '').toString(),
      updatedAt: (data['updated_at'] ?? '').toString(),
      modifiedAt: (data['modified_at'] ?? '').toString(),
      createdBy: data['created_by']?.toString(),
      modifiedBy: data['modified_by']?.toString(),
      isDeleted: data['is_deleted'] == true,
      userId: (data['user_id'] ?? '').toString(),
      serviceId: _parseInt(data['service_id']),
      barberShopId: _parseInt(data['barber_shop_id']),
      barberId: _parseInt(data['barber_id']),
      date: (data['date'] ?? '').toString(),
      time: (data['time'] ?? '').toString(),
      reminderSent: data['reminder_sent'] == true,
      paymentStatus: (data['payment_status'] ?? 'pending').toString(),
      status: (data['status'] ?? 'pending').toString(),
      paymentModel: (data['payment_model'] ?? 'cash').toString(),
      orderType: (data['order_type'] ?? 'online').toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'modified_at': modifiedAt,
      'created_by': createdBy,
      'modified_by': modifiedBy,
      'is_deleted': isDeleted,
      'user_id': userId,
      'service_id': serviceId,
      'barber_shop_id': barberShopId,
      'barber_id': barberId,
      'date': date,
      'time': time,
      'reminder_sent': reminderSent,
      'payment_status': paymentStatus,
      'status': status,
      'payment_model': paymentModel,
      'order_type': orderType,
    };
  }
}