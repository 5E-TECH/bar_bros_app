import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class GetChatConversationEvent extends ChatEvent {
  final String userId;
  final String barberId;

  const GetChatConversationEvent({
    required this.userId,
    required this.barberId,
  });

  @override
  List<Object?> get props => [userId, barberId];
}

class GetMyChatsEvent extends ChatEvent {
  const GetMyChatsEvent();
}

class SendMessageEvent extends ChatEvent {
  final String message;
  final String barberId;
  final String? imagePath;

  const SendMessageEvent({
    required this.message,
    required this.barberId,
    this.imagePath,
  });

  @override
  List<Object?> get props => [message, barberId, imagePath];
}
