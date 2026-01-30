import 'package:bar_bros_user/features/notification/domain/entities/notification_item.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationItem> items;
  final Map<String, String> barberNames;

  const NotificationLoaded(this.items, {this.barberNames = const {}});

  @override
  List<Object?> get props => [items, barberNames];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
