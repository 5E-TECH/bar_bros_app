import 'package:equatable/equatable.dart';

class NotificationItem extends Equatable {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String modifiedAt;
  final String? createdBy;
  final String? modifiedBy;
  final bool isDeleted;
  final String message;
  final bool isRead;
  final String? userId;
  final String? barberId;
  final String? barberName;
  final String? barberShopId;

  const NotificationItem({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.modifiedAt,
    required this.createdBy,
    required this.modifiedBy,
    required this.isDeleted,
    required this.message,
    required this.isRead,
    required this.userId,
    required this.barberId,
    required this.barberName,
    required this.barberShopId,
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
        message,
        isRead,
        userId,
        barberId,
        barberName,
        barberShopId,
      ];
}
