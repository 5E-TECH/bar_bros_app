import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:bar_bros_user/core/error/errors_server_exceptions.dart';
import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/features/service/data/models/service_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class ServiceRemoteDataSource {
  Future<List<ServiceModel>> getAllServices(String token);
}

@LazySingleton(as: ServiceRemoteDataSource)
class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final Dio _dio;

  ServiceRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ServiceModel>> getAllServices(String token) async {
    try {
      final response = await _dio.get(
        Constants.getAllServices,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data
            .map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
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
}
