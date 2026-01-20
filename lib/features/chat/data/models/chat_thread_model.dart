import 'package:bar_bros_user/features/chat/domain/entities/chat_thread.dart';

class ChatThreadModel extends ChatThread {
  const ChatThreadModel({
    required super.id,
    required super.userId,
    required super.barberId,
    required super.lastMessage,
    required super.updatedAt,
  });

  factory ChatThreadModel.fromJson(Map<String, dynamic> json) {
    final updatedAt = json['updated_at'] ??
        json['modified_at'] ??
        json['created_at'] ??
        '';
    final lastMessageValue = json['last_message'] ?? json['message'] ?? '';
    return ChatThreadModel(
      id: json['id']?.toString() ?? '',
      userId: (json['user_id'] ?? json['userId'])?.toString() ?? '',
      barberId: (json['barber_id'] ?? json['barberId'])?.toString() ?? '',
      lastMessage: lastMessageValue.toString(),
      updatedAt: updatedAt.toString(),
    );
  }
}
