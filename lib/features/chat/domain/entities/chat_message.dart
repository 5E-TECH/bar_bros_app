import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String message;
  final String userId;
  final String barberId;
  final String imageUrl;
  final String createdAt;
  final String senderRole;

  const ChatMessage({
    required this.id,
    required this.message,
    required this.userId,
    required this.barberId,
    required this.imageUrl,
    required this.createdAt,
    required this.senderRole,
  });

  @override
  List<Object?> get props => [
        id,
        message,
        userId,
        barberId,
        imageUrl,
        createdAt,
        senderRole,
      ];
}
