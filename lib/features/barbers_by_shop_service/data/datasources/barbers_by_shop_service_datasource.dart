import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:bar_bros_user/core/error/errors_server_exceptions.dart';
import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/features/barbers_by_shop_service/data/models/barber_by_shop_service_model.dart';
import 'package:bar_bros_user/features/barbers_by_shop_service/domain/entities/barbers_by_shop_service_query.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class BarbersByShopServiceRemoteDataSource {
  Future<List<BarberByShopServiceModel>> getBarbersByShopService(
    String token,
    BarbersByShopServiceQuery query,
  );
}

@LazySingleton(as: BarbersByShopServiceRemoteDataSource)
class BarbersByShopServiceRemoteDataSourceImpl
    implements BarbersByShopServiceRemoteDataSource {
  final Dio _dio;

  BarbersByShopServiceRemoteDataSourceImpl(this._dio);

  @override
  Future<List<BarberByShopServiceModel>> getBarbersByShopService(
    String token,
    BarbersByShopServiceQuery query,
  ) async {
    try {
      final response = await _dio.get(
        Constants.getBarbersByShopAndService,
        queryParameters: {
          'barberShopId': query.barberShopId,
          'serviceId': query.serviceId,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data
            .map((json) =>
                BarberByShopServiceModel.fromJson(json as Map<String, dynamic>))
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
