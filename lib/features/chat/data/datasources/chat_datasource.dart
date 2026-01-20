import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:bar_bros_user/core/error/errors_server_exceptions.dart';
import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/features/chat/data/models/chat_message_model.dart';
import 'package:bar_bros_user/features/chat/data/models/chat_thread_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';

abstract class ChatRemoteDataSource {
  Future<List<ChatMessageModel>> getConversation(
    String token, {
    required String userId,
    required String barberId,
  });

  Future<List<ChatThreadModel>> getMyChats(String token);

  Future<ChatMessageModel> sendMessage(
    String token, {
    required String message,
    required String userId,
    required String barberId,
    String? imagePath,
  });
}

@LazySingleton(as: ChatRemoteDataSource)
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio _dio;

  ChatRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ChatMessageModel>> getConversation(
    String token, {
    required String userId,
    required String barberId,
  }) async {
    try {
      final response = await _dio.get(
        Constants.chatConversation,
        queryParameters: {
          'user_id': userId,
          'barber_id': barberId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data
            .map((json) =>
                ChatMessageModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(CustomExceptionsText.failed);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw ServerException(CustomExceptionsText.unauthorized);
      }
      throw NetworkException(e.message ?? CustomExceptionsText.network);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ChatThreadModel>> getMyChats(String token) async {
    try {
      final response = await _dio.get(
        Constants.chatMy,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data
            .map((json) =>
                ChatThreadModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(CustomExceptionsText.failed);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw ServerException(CustomExceptionsText.unauthorized);
      }
      throw NetworkException(e.message ?? CustomExceptionsText.network);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ChatMessageModel> sendMessage(
    String token, {
    required String message,
    required String userId,
    required String barberId,
    String? imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'message': message,
        'user_id': userId,
        'barber_id': barberId,
        if (imagePath != null && imagePath.isNotEmpty)
          'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post(
        Constants.chatSend,
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ChatMessageModel.fromJson(data);
      } else {
        throw ServerException(CustomExceptionsText.failed);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw ServerException(CustomExceptionsText.unauthorized);
      }
      throw NetworkException(e.message ?? CustomExceptionsText.network);
    } on FileSystemException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
