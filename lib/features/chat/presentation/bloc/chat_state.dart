import 'package:bar_bros_user/features/chat/domain/entities/chat_message.dart';
import 'package:bar_bros_user/features/chat/domain/entities/chat_thread.dart';
import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatConversationLoaded extends ChatState {
  final List<ChatMessage> messages;

  const ChatConversationLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatThreadsLoaded extends ChatState {
  final List<ChatThread> threads;

  const ChatThreadsLoaded(this.threads);

  @override
  List<Object?> get props => [threads];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class SendMessageLoading extends ChatState {}

class SendMessageSuccess extends ChatState {
  final ChatMessage message;

  const SendMessageSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
