import 'package:equatable/equatable.dart';

class ChatThread extends Equatable {
  final String id;
  final String userId;
  final String barberId;
  final String lastMessage;
  final String updatedAt;

  const ChatThread({
    required this.id,
    required this.userId,
    required this.barberId,
    required this.lastMessage,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        barberId,
        lastMessage,
        updatedAt,
      ];
}
