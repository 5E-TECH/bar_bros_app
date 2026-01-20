import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:bar_bros_user/core/error/errors_server_exceptions.dart';
import 'package:bar_bros_user/core/error/exceptions.dart';
import 'package:bar_bros_user/features/barber_shop_services/data/models/barber_shop_service_model.dart';
import 'package:bar_bros_user/features/barber_shop_services/domain/entities/barber_shop_service_query.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class BarberShopServiceRemoteDataSource {
  Future<List<BarberShopServiceModel>> getAllBarberShopServices(
    String token,
    BarberShopServiceQuery query,
  );
}

@LazySingleton(as: BarberShopServiceRemoteDataSource)
class BarberShopServiceRemoteDataSourceImpl
    implements BarberShopServiceRemoteDataSource {
  final Dio _dio;

  BarberShopServiceRemoteDataSourceImpl(this._dio);

  @override
  Future<List<BarberShopServiceModel>> getAllBarberShopServices(
    String token,
    BarberShopServiceQuery query,
  ) async {
    try {
      final response = await _dio.get(
        Constants.getBarberShopServices,
        queryParameters: {
          'serviceId': query.serviceId,
          if (query.distance != null) 'distance': query.distance,
          if (query.avgRating != null) 'avg_rating': query.avgRating,
          if (query.radiusKm != null) 'radiusKm': query.radiusKm,
          if (query.lng != null) 'lng': query.lng,
          if (query.lat != null) 'lat': query.lat,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data
            .map((json) =>
                BarberShopServiceModel.fromJson(json as Map<String, dynamic>))
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
