import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:bar_bros_user/core/error/errors_server_exceptions.dart';
import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/features/category/data/models/category_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getAllCategories(String token);
  Future<List<CategoryModel>> getAllManCategories(String token);
  Future<List<CategoryModel>> getAllWomanCategories(String token);
}

@LazySingleton(as: CategoryRemoteDataSource)
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final Dio _dio;

  CategoryRemoteDataSourceImpl(this._dio);

  @override
  Future<List<CategoryModel>> getAllCategories(String token) async {
    return _fetchCategories(Constants.getAllCategories, token);
  }

  @override
  Future<List<CategoryModel>> getAllManCategories(String token) async {
    return _fetchCategories(
      Constants.getAllCategories,
      token,
      categoryType: 'man',
    );
  }

  @override
  Future<List<CategoryModel>> getAllWomanCategories(String token) async {
    return _fetchCategories(
      Constants.getAllCategories,
      token,
      categoryType: 'woman',
    );
  }

  Future<List<CategoryModel>> _fetchCategories(
    String endpoint,
    String token, {
    String? categoryType,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters:
            categoryType == null ? null : {'categoryType': categoryType},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(CustomExceptionsText.failed);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 404) {
        throw ServerException(CustomExceptionsText.unauthorized);
      }
      throw NetworkException(e.message ?? CustomExceptionsText.network);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
