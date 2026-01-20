import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:bar_bros_user/core/error/errors_server_exceptions.dart';
import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/features/barber_shop/data/models/barber_shop_item_model.dart';
import 'package:bar_bros_user/features/barber_shop/domain/entities/barber_shop_query.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class BarberShopRemoteDataSource {
  Future<List<BarberShopItemModel>> getBarberShops(
    String token,
    BarberShopQuery query,
  );
}

@LazySingleton(as: BarberShopRemoteDataSource)
class BarberShopRemoteDataSourceImpl implements BarberShopRemoteDataSource {
  final Dio _dio;

  BarberShopRemoteDataSourceImpl(this._dio);

  @override
  Future<List<BarberShopItemModel>> getBarberShops(
    String token,
    BarberShopQuery query,
  ) async {
    try {
      final response = await _dio.get(
        Constants.getBarberShops,
        queryParameters: {
          'limit': query.limit,
          'page': query.page,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final dataRoot = response.data['data'] as Map<String, dynamic>;
        final List<dynamic> data = dataRoot['data'] as List<dynamic>;
        return data
            .map((json) =>
                BarberShopItemModel.fromJson(json as Map<String, dynamic>))
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
