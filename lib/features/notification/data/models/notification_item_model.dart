import 'package:bar_bros_user/features/notification/domain/entities/notification_item.dart';

class NotificationItemModel extends NotificationItem {
  const NotificationItemModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.modifiedAt,
    required super.createdBy,
    required super.modifiedBy,
    required super.isDeleted,
    required super.message,
    required super.isRead,
    required super.userId,
    required super.barberId,
    required super.barberName,
    required super.barberShopId,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: _asString(json['id']),
      createdAt: _asString(json['created_at']),
      updatedAt: _asString(json['updated_at']),
      modifiedAt: _asString(json['modified_at']),
      createdBy: _asNullableString(json['created_by']),
      modifiedBy: _asNullableString(json['modified_by']),
      isDeleted: json['is_deleted'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      userId: _asNullableString(json['user_id']),
      barberId: _asNullableString(json['barber_id']),
      barberName: _asNullableString(json['barber_name']),
      barberShopId: _asNullableString(json['barber_shop_id']),
    );
  }

  static String _asString(Object? value) {
    if (value == null) return '';
    return value.toString();
  }

  static String? _asNullableString(Object? value) {
    if (value == null) return null;
    final stringValue = value.toString();
    return stringValue.isEmpty ? null : stringValue;
  }
}
