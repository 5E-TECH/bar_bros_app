import 'package:bar_bros_user/features/chat/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.message,
    required super.userId,
    required super.barberId,
    required super.imageUrls,
    required super.createdAt,
    required super.senderRole,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final imageValue = json['image'];
    final imageUrls = imageValue is List
        ? imageValue.map((item) => item?.toString() ?? '').toList()
        : imageValue is String
            ? (imageValue.isEmpty ? const <String>[] : [imageValue])
            : const <String>[];
    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      message: json['message'] as String? ?? '',
      userId: json['user_id']?.toString() ?? '',
      barberId: json['barber_id']?.toString() ?? '',
      imageUrls: imageUrls,
      createdAt: json['created_at']?.toString() ?? '',
      senderRole: json['sender_role']?.toString() ?? '',
    );
  }
}
