import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:bar_bros_user/features/chat/domain/usecases/get_chat_conversation_usecase.dart';
import 'package:bar_bros_user/features/chat/domain/usecases/get_my_chats_usecase.dart';
import 'package:bar_bros_user/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'chat_event.dart';
import 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatConversationUseCase _getConversationUseCase;
  final GetMyChatsUseCase _getMyChatsUseCase;
  final SendMessageUseCase _sendMessageUseCase;

  ChatBloc(
    this._getConversationUseCase,
    this._getMyChatsUseCase,
    this._sendMessageUseCase,
  ) : super(ChatInitial()) {
    on<GetChatConversationEvent>(_onGetConversation);
    on<GetMyChatsEvent>(_onGetMyChats);
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onGetConversation(
    GetChatConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());

    final result = await _getConversationUseCase(
      GetChatConversationParams(
        userId: event.userId,
        barberId: event.barberId,
      ),
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (messages) => emit(ChatConversationLoaded(messages)),
    );
  }

  Future<void> _onGetMyChats(
    GetMyChatsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());

    final result = await _getMyChatsUseCase(NoParams());

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (threads) => emit(ChatThreadsLoaded(threads)),
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(SendMessageLoading());

    final result = await _sendMessageUseCase(
      SendMessageParams(
        message: event.message,
        barberId: event.barberId,
        imagePath: event.imagePath,
      ),
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (message) => emit(SendMessageSuccess(message)),
    );
  }
}
