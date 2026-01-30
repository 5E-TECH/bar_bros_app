import 'package:bar_bros_user/core/di/ingector.dart';
import 'package:bar_bros_user/core/wrappers/app_wrapper.dart';
import 'package:bar_bros_user/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bar_bros_user/features/barber_shop_services/presentation/bloc/barber_shop_service_bloc.dart';
import 'package:bar_bros_user/features/booking_availability/presentation/bloc/booking_availability_bloc.dart';
import 'package:bar_bros_user/features/category/presentation/bloc/category_bloc.dart';
import 'package:bar_bros_user/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:bar_bros_user/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:bar_bros_user/features/notification/presentation/bloc/notification_event.dart';
import 'package:bar_bros_user/features/service/presentation/bloc/service_bloc.dart';
import 'package:bar_bros_user/features/theme/bloc/theme_bloc.dart';
import 'package:bar_bros_user/features/user_booking/presentation/bloc/user_booking_bloc.dart';
import 'package:bar_bros_user/core/notifications/fcm_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FcmService.initialize();

  await configureDependencies();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('uz'), Locale('ru'), Locale('en')],
      path: 'assets/translate',
      fallbackLocale: const Locale('uz'),
      useOnlyLangCode: true,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => getIt<ThemeBloc>()),
            BlocProvider(create: (context) => getIt<AuthBloc>()),
            BlocProvider(
              create: (context) =>
                  getIt<CategoryBloc>()..add(const GetAllCategoriesEvent()),
            ),
            BlocProvider(create: (context) => getIt<ServiceBloc>()),
            BlocProvider(create: (context) => getIt<BarberShopServiceBloc>()),
            BlocProvider(create: (context) => getIt<ChatBloc>()),
            BlocProvider(create: (context) => getIt<BarberShopServiceBloc>()),
            BlocProvider(create: (context) => getIt<BookingAvailabilityBloc>()),
            BlocProvider(create: (context) => getIt<UserBookingBloc>()),
            BlocProvider(
              create: (context) =>
                  getIt<NotificationBloc>()..add(const GetMyNotificationsEvent()),
            ),
          ],
          child: AppWrapper(),
        );
      },
    );
  }
}
