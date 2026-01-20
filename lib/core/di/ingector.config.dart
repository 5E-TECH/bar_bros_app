// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:bar_bros_user/core/network/dio_client.dart' as _i692;
import 'package:bar_bros_user/core/storage/local_storage.dart' as _i726;
import 'package:bar_bros_user/features/auth/data/datasources/auth_datasource.dart'
    as _i827;
import 'package:bar_bros_user/features/auth/data/repositories/auth_repository_impl.dart'
    as _i1018;
import 'package:bar_bros_user/features/auth/domain/repositories/auth_repository.dart'
    as _i767;
import 'package:bar_bros_user/features/auth/domain/usecases/check_auth_usecase.dart'
    as _i919;
import 'package:bar_bros_user/features/auth/domain/usecases/get_my_account_usecase.dart'
    as _i811;
import 'package:bar_bros_user/features/auth/domain/usecases/logout_usecase.dart'
    as _i737;
import 'package:bar_bros_user/features/auth/domain/usecases/register_usecase.dart'
    as _i1020;
import 'package:bar_bros_user/features/auth/domain/usecases/set_fullName_usecase.dart'
    as _i174;
import 'package:bar_bros_user/features/auth/domain/usecases/verify_code_usecase.dart'
    as _i10;
import 'package:bar_bros_user/features/auth/presentation/bloc/auth_bloc.dart'
    as _i189;
import 'package:bar_bros_user/features/barber_shop/data/datasources/barber_shop_datasource.dart'
    as _i713;
import 'package:bar_bros_user/features/barber_shop/data/repositories/barber_shop_repository_impl.dart'
    as _i846;
import 'package:bar_bros_user/features/barber_shop/domain/repositories/barber_shop_repository.dart'
    as _i786;
import 'package:bar_bros_user/features/barber_shop/domain/usecases/get_barber_shops_usecase.dart'
    as _i710;
import 'package:bar_bros_user/features/barber_shop/presentation/bloc/barber_shop_bloc.dart'
    as _i122;
import 'package:bar_bros_user/features/barber_shop_services/data/datasources/barber_shop_service_datasource.dart'
    as _i698;
import 'package:bar_bros_user/features/barber_shop_services/data/repositories/barber_shop_service_repository_impl.dart'
    as _i395;
import 'package:bar_bros_user/features/barber_shop_services/domain/repositories/barber_shop_service_repository.dart'
    as _i335;
import 'package:bar_bros_user/features/barber_shop_services/domain/usecases/get_all_barber_shop_services_usecase.dart'
    as _i1043;
import 'package:bar_bros_user/features/barber_shop_services/presentation/bloc/barber_shop_service_bloc.dart'
    as _i978;
import 'package:bar_bros_user/features/barbers_by_shop_service/data/datasources/barbers_by_shop_service_datasource.dart'
    as _i386;
import 'package:bar_bros_user/features/barbers_by_shop_service/data/repositories/barbers_by_shop_service_repository_impl.dart'
    as _i27;
import 'package:bar_bros_user/features/barbers_by_shop_service/domain/repositories/barbers_by_shop_service_repository.dart'
    as _i635;
import 'package:bar_bros_user/features/barbers_by_shop_service/domain/usecases/get_barbers_by_shop_service_usecase.dart'
    as _i1200;
import 'package:bar_bros_user/features/barbers_by_shop_service/presentation/bloc/barbers_by_shop_service_bloc.dart'
    as _i1201;
import 'package:bar_bros_user/features/booking/data/datasources/booking_datasource.dart'
    as _i244;
import 'package:bar_bros_user/features/booking/data/repositories/booking_repository_impl.dart'
    as _i978;
import 'package:bar_bros_user/features/booking/domain/repositories/booking_repository.dart'
    as _i560;
import 'package:bar_bros_user/features/booking/domain/usecases/create_booking_usecase.dart'
    as _i409;
import 'package:bar_bros_user/features/booking/presentation/bloc/booking_bloc.dart'
    as _i273;
import 'package:bar_bros_user/features/booking_availability/data/datasources/booking_availability_datasource.dart'
    as _i851;
import 'package:bar_bros_user/features/booking_availability/data/repositories/booking_availability_repository_impl.dart'
    as _i947;
import 'package:bar_bros_user/features/booking_availability/domain/repositories/booking_availability_repository.dart'
    as _i782;
import 'package:bar_bros_user/features/booking_availability/domain/usecases/get_booking_availability_usecase.dart'
    as _i1202;
import 'package:bar_bros_user/features/booking_availability/presentation/bloc/booking_availability_bloc.dart'
    as _i1203;
import 'package:bar_bros_user/features/booking_availability_range/data/datasources/booking_availability_range_datasource.dart'
    as _i630;
import 'package:bar_bros_user/features/booking_availability_range/data/repositories/booking_availability_range_repository_impl.dart'
    as _i80;
import 'package:bar_bros_user/features/booking_availability_range/domain/repositories/booking_availability_range_repository.dart'
    as _i829;
import 'package:bar_bros_user/features/booking_availability_range/domain/usecases/get_booking_availability_range_usecase.dart'
    as _i1204;
import 'package:bar_bros_user/features/booking_availability_range/presentation/bloc/booking_availability_range_bloc.dart'
    as _i1205;
import 'package:bar_bros_user/features/category/data/datasources/category_datasource.dart'
    as _i866;
import 'package:bar_bros_user/features/category/data/repositories/category_repository_impl.dart'
    as _i571;
import 'package:bar_bros_user/features/category/domain/repositories/category_repository.dart'
    as _i1006;
import 'package:bar_bros_user/features/category/domain/usecases/get_all_categories_usecase.dart'
    as _i915;
import 'package:bar_bros_user/features/category/domain/usecases/get_all_man_categories_usecase.dart'
    as _i575;
import 'package:bar_bros_user/features/category/domain/usecases/get_all_woman_categories_usecase.dart'
    as _i1066;
import 'package:bar_bros_user/features/category/presentation/bloc/category_bloc.dart'
    as _i797;
import 'package:bar_bros_user/features/chat/data/datasources/chat_datasource.dart'
    as _i763;
import 'package:bar_bros_user/features/chat/data/repositories/chat_repository_impl.dart'
    as _i301;
import 'package:bar_bros_user/features/chat/domain/repositories/chat_repository.dart'
    as _i971;
import 'package:bar_bros_user/features/chat/domain/usecases/get_chat_conversation_usecase.dart'
    as _i760;
import 'package:bar_bros_user/features/chat/domain/usecases/get_my_chats_usecase.dart'
    as _i26;
import 'package:bar_bros_user/features/chat/domain/usecases/send_message_usecase.dart'
    as _i205;
import 'package:bar_bros_user/features/chat/presentation/bloc/chat_bloc.dart'
    as _i504;
import 'package:bar_bros_user/features/service/data/datasources/service_datasource.dart'
    as _i983;
import 'package:bar_bros_user/features/service/data/repositories/service_repository_impl.dart'
    as _i344;
import 'package:bar_bros_user/features/service/domain/repositories/service_repository.dart'
    as _i306;
import 'package:bar_bros_user/features/service/domain/usecases/get_all_services_usecase.dart'
    as _i4;
import 'package:bar_bros_user/features/service/presentation/bloc/service_bloc.dart'
    as _i990;
import 'package:bar_bros_user/features/theme/bloc/theme_bloc.dart' as _i857;
import 'package:bar_bros_user/features/user_booking/data/datasources/user_booking_datasource.dart'
    as _i1300;
import 'package:bar_bros_user/features/user_booking/data/repositories/user_booking_repository_impl.dart'
    as _i1301;
import 'package:bar_bros_user/features/user_booking/domain/repositories/user_booking_repository.dart'
    as _i1302;
import 'package:bar_bros_user/features/user_booking/domain/usecases/get_user_bookings_usecase.dart'
    as _i1303;
import 'package:bar_bros_user/features/user_booking/presentation/bloc/user_booking_bloc.dart'
    as _i1304;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final storageModule = _$StorageModule();
    final networkModule = _$NetworkModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => storageModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i857.ThemeBloc>(() => _i857.ThemeBloc());
    gh.lazySingleton<_i630.BookingAvailabilityRangeRemoteDataSource>(
      () => _i630.BookingAvailabilityRangeRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i983.ServiceRemoteDataSource>(
      () => _i983.ServiceRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i244.BookingRemoteDataSource>(
      () => _i244.BookingRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i851.BookingAvailabilityRemoteDataSource>(
      () => _i851.BookingAvailabilityRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i698.BarberShopServiceRemoteDataSource>(
      () => _i698.BarberShopServiceRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i386.BarbersByShopServiceRemoteDataSource>(
      () => _i386.BarbersByShopServiceRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i1300.UserBookingRemoteDataSource>(
      () => _i1300.UserBookingRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i726.LocalStorage>(
      () => _i726.LocalStorageImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i829.BookingAvailabilityRangeRepository>(
      () => _i80.BookingAvailabilityRangeRepositoryImpl(
        gh<_i630.BookingAvailabilityRangeRemoteDataSource>(),
        gh<_i726.LocalStorage>(),
      ),
    );
    gh.lazySingleton<_i1204.GetBookingAvailabilityRangeUseCase>(
      () => _i1204.GetBookingAvailabilityRangeUseCase(
        gh<_i829.BookingAvailabilityRangeRepository>(),
      ),
    );
    gh.lazySingleton<_i827.AuthRemoteDataSource>(
      () => _i827.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i763.ChatRemoteDataSource>(
      () => _i763.ChatRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i866.CategoryRemoteDataSource>(
      () => _i866.CategoryRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i713.BarberShopRemoteDataSource>(
      () => _i713.BarberShopRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i782.BookingAvailabilityRepository>(
      () => _i947.BookingAvailabilityRepositoryImpl(
        gh<_i851.BookingAvailabilityRemoteDataSource>(),
        gh<_i726.LocalStorage>(),
      ),
    );
    gh.lazySingleton<_i1202.GetBookingAvailabilityUseCase>(
      () => _i1202.GetBookingAvailabilityUseCase(
        gh<_i782.BookingAvailabilityRepository>(),
      ),
    );
    gh.lazySingleton<_i335.BarberShopServiceRepository>(
      () => _i395.BarberShopServiceRepositoryImpl(
        gh<_i698.BarberShopServiceRemoteDataSource>(),
        gh<_i726.LocalStorage>(),
      ),
    );
    gh.lazySingleton<_i1006.CategoryRepository>(
      () => _i571.CategoryRepositoryImpl(
        gh<_i866.CategoryRemoteDataSource>(),
        gh<_i726.LocalStorage>(),
      ),
    );
    gh.lazySingleton<_i767.AuthRepository>(
      () => _i1018.AuthRepositoryImpl(
        gh<_i827.AuthRemoteDataSource>(),
        gh<_i726.LocalStorage>(),
      ),
    );
    gh.lazySingleton<_i635.BarbersByShopServiceRepository>(
      () => _i27.BarbersByShopServiceRepositoryImpl(
        gh<_i386.BarbersByShopServiceRemoteDataSource>(),
        gh<_i726.LocalStorage>(),
      ),
    );
    gh.lazySingleton<_i1302.UserBookingRepository>(
      () => _i1301.UserBookingRepositoryImpl(
        gh<_i1300.UserBookingRemoteDataSource>(),
        gh<_i726.LocalStorage>(),
      ),
    );
    gh.lazySingleton<_i1200.GetBarbersByShopServiceUseCase>(
      () => _i1200.GetBarbersByShopServiceUseCase(
        gh<_i635.BarbersByShopServiceRepository>(),
      ),
    );
    gh.lazySingleton<_i1303.GetUserBookingsUseCase>(
      () => _i1303.GetUserBookingsUseCase(
        gh<_i1302.UserBookingRepository>(),
      ),
    );
    gh.lazySingleton<_i971.ChatRepository>(
      () => _i301.ChatRepositoryImpl(
        gh<_i763.ChatRemoteDataSource>(),
        gh<_i726.LocalStorage>(),
      ),
    );
    gh.lazySingleton<_i1043.GetAllBarberShopServicesUseCase>(
      () => _i1043.GetAllBarberShopServicesUseCase(
        gh<_i335.BarberShopServiceRepository>(),
      ),
    );
    gh.lazySingleton<_i560.BookingRepository>(
      () => _i978.BookingRepositoryImpl(
        gh<_i244.BookingRemoteDataSource>(),
        gh<_i726.LocalStorage>(),
      ),
    );
    gh.lazySingleton<_i919.CheckAuthUseCase>(
      () => _i919.CheckAuthUseCase(gh<_i726.LocalStorage>()),
    );
    gh.lazySingleton<_i737.LogOutUseCase>(
      () => _i737.LogOutUseCase(gh<_i726.LocalStorage>()),
    );
    gh.lazySingleton<_i786.BarberShopRepository>(
      () => _i846.BarberShopRepositoryImpl(
        gh<_i713.BarberShopRemoteDataSource>(),
        gh<_i726.LocalStorage>(),
      ),
    );
    gh.lazySingleton<_i760.GetChatConversationUseCase>(
      () => _i760.GetChatConversationUseCase(gh<_i971.ChatRepository>()),
    );
    gh.lazySingleton<_i26.GetMyChatsUseCase>(
      () => _i26.GetMyChatsUseCase(gh<_i971.ChatRepository>()),
    );
    gh.lazySingleton<_i205.SendMessageUseCase>(
      () => _i205.SendMessageUseCase(gh<_i971.ChatRepository>()),
    );
    gh.lazySingleton<_i811.GetMyAccountUseCase>(
      () => _i811.GetMyAccountUseCase(gh<_i767.AuthRepository>()),
    );
    gh.lazySingleton<_i1020.RegisterUseCase>(
      () => _i1020.RegisterUseCase(gh<_i767.AuthRepository>()),
    );
    gh.lazySingleton<_i174.SetFullNameUseCase>(
      () => _i174.SetFullNameUseCase(gh<_i767.AuthRepository>()),
    );
    gh.lazySingleton<_i10.VerifyCodeUseCase>(
      () => _i10.VerifyCodeUseCase(gh<_i767.AuthRepository>()),
    );
    gh.lazySingleton<_i306.ServiceRepository>(
      () => _i344.ServiceRepositoryImpl(
        gh<_i983.ServiceRemoteDataSource>(),
        gh<_i726.LocalStorage>(),
      ),
    );
    gh.factory<_i504.ChatBloc>(
      () => _i504.ChatBloc(
        gh<_i760.GetChatConversationUseCase>(),
        gh<_i26.GetMyChatsUseCase>(),
        gh<_i205.SendMessageUseCase>(),
      ),
    );
    gh.factory<_i189.AuthBloc>(
      () => _i189.AuthBloc(
        gh<_i1020.RegisterUseCase>(),
        gh<_i10.VerifyCodeUseCase>(),
        gh<_i174.SetFullNameUseCase>(),
        gh<_i919.CheckAuthUseCase>(),
        gh<_i737.LogOutUseCase>(),
        gh<_i811.GetMyAccountUseCase>(),
        gh<_i726.LocalStorage>(),
      ),
    );
    gh.lazySingleton<_i710.GetBarberShopsUseCase>(
      () => _i710.GetBarberShopsUseCase(gh<_i786.BarberShopRepository>()),
    );
    gh.factory<_i122.BarberShopBloc>(
      () => _i122.BarberShopBloc(gh<_i710.GetBarberShopsUseCase>()),
    );
    gh.lazySingleton<_i915.GetAllCategoriesUseCase>(
      () => _i915.GetAllCategoriesUseCase(gh<_i1006.CategoryRepository>()),
    );
    gh.lazySingleton<_i575.GetAllManCategoriesUseCase>(
      () => _i575.GetAllManCategoriesUseCase(gh<_i1006.CategoryRepository>()),
    );
    gh.lazySingleton<_i1066.GetAllWomanCategoriesUseCase>(
      () =>
          _i1066.GetAllWomanCategoriesUseCase(gh<_i1006.CategoryRepository>()),
    );
    gh.lazySingleton<_i409.CreateBookingUseCase>(
      () => _i409.CreateBookingUseCase(gh<_i560.BookingRepository>()),
    );
    gh.factory<_i978.BarberShopServiceBloc>(
      () => _i978.BarberShopServiceBloc(
        gh<_i1043.GetAllBarberShopServicesUseCase>(),
      ),
    );
    gh.factory<_i1203.BookingAvailabilityBloc>(
      () => _i1203.BookingAvailabilityBloc(
        gh<_i1202.GetBookingAvailabilityUseCase>(),
      ),
    );
    gh.factory<_i1201.BarbersByShopServiceBloc>(
      () => _i1201.BarbersByShopServiceBloc(
        gh<_i1200.GetBarbersByShopServiceUseCase>(),
      ),
    );
    gh.factory<_i1205.BookingAvailabilityRangeBloc>(
      () => _i1205.BookingAvailabilityRangeBloc(
        gh<_i1204.GetBookingAvailabilityRangeUseCase>(),
      ),
    );
    gh.factory<_i1304.UserBookingBloc>(
      () => _i1304.UserBookingBloc(
        gh<_i1303.GetUserBookingsUseCase>(),
      ),
    );
    gh.lazySingleton<_i4.GetAllServicesUseCase>(
      () => _i4.GetAllServicesUseCase(gh<_i306.ServiceRepository>()),
    );
    gh.factory<_i273.BookingBloc>(
      () => _i273.BookingBloc(gh<_i409.CreateBookingUseCase>()),
    );
    gh.factory<_i797.CategoryBloc>(
      () => _i797.CategoryBloc(
        gh<_i915.GetAllCategoriesUseCase>(),
        gh<_i575.GetAllManCategoriesUseCase>(),
        gh<_i1066.GetAllWomanCategoriesUseCase>(),
      ),
    );
    gh.factory<_i990.ServiceBloc>(
      () => _i990.ServiceBloc(gh<_i4.GetAllServicesUseCase>()),
    );
    return this;
  }
}

class _$StorageModule extends _i726.StorageModule {}

class _$NetworkModule extends _i692.NetworkModule {}
