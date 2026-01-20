import 'package:bar_bros_user/features/chat/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.message,
    required super.userId,
    required super.barberId,
    required super.imageUrl,
    required super.createdAt,
    required super.senderRole,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      message: json['message'] as String? ?? '',
      userId: json['user_id']?.toString() ?? '',
      barberId: json['barber_id']?.toString() ?? '',
      imageUrl: json['image'] as String? ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      senderRole: json['sender_role']?.toString() ?? '',
    );
  }
}
