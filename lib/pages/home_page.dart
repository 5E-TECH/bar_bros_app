import 'dart:async';
import 'dart:io';

import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/core/widgets/home_page_widgets/promo_card.dart';
import 'package:bar_bros_user/core/widgets/home_page_widgets/service_category_widget.dart';
import 'package:bar_bros_user/core/widgets/logout_button.dart';
import 'package:bar_bros_user/core/di/ingector.dart';
import 'package:bar_bros_user/core/storage/local_storage.dart';
import 'package:bar_bros_user/features/barber_shop_services/domain/entities/barber_shop_service.dart';
import 'package:bar_bros_user/features/barber_shop_services/domain/entities/barber_shop_service_query.dart';
import 'package:bar_bros_user/features/barber_shop_services/domain/usecases/get_all_barber_shop_services_usecase.dart';
import 'package:bar_bros_user/features/category/domain/entities/category.dart';
import 'package:bar_bros_user/features/category/presentation/bloc/category_bloc.dart';
import 'package:bar_bros_user/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:bar_bros_user/features/notification/presentation/bloc/notification_event.dart';
import 'package:bar_bros_user/features/notification/presentation/bloc/notification_state.dart';
import 'package:bar_bros_user/features/service/domain/entities/service.dart';
import 'package:bar_bros_user/features/service/presentation/bloc/service_bloc.dart';
import 'package:bar_bros_user/features/service/presentation/bloc/service_event.dart';
import 'package:bar_bros_user/features/service/presentation/bloc/service_state.dart';
import 'package:bar_bros_user/features/theme/bloc/theme_bloc.dart';
import 'package:bar_bros_user/features/user_booking/domain/entities/user_booking.dart';
import 'package:bar_bros_user/features/user_booking/presentation/bloc/user_booking_bloc.dart';
import 'package:bar_bros_user/features/user_booking/presentation/bloc/user_booking_event.dart';
import 'package:bar_bros_user/features/user_booking/presentation/bloc/user_booking_state.dart';
import 'package:bar_bros_user/models/barbershop.dart';
import 'package:bar_bros_user/pages/about_app_page.dart';
import 'package:bar_bros_user/pages/barbershop_detail.dart';
import 'package:bar_bros_user/pages/berbers_page.dart';
import 'package:bar_bros_user/pages/category/man_categories_page.dart';
import 'package:bar_bros_user/pages/category/woman_categories_page.dart';
import 'package:bar_bros_user/pages/contact_page.dart';
import 'package:bar_bros_user/pages/credit_card/cards_page.dart';
import 'package:bar_bros_user/pages/notifications_page.dart';
import 'package:bar_bros_user/pages/profile/edit_profile_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class BarbershopHomeScreen extends StatefulWidget {
  const BarbershopHomeScreen({super.key});

  @override
  State<BarbershopHomeScreen> createState() => _BarbershopHomeScreenState();
}

class _BarbershopHomeScreenState extends State<BarbershopHomeScreen> {
  final PageController _promoPageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  Timer? _autoScrollRestartTimer;
  CategoryState? _cachedState;
  int _promoPageCount = 0;
  Set<String> _locallyReadNotificationIds = {};

  String _userName = '';
  String? _userImagePath;
  List<BarberShopService> _nearbyShops = [];
  bool _nearbyLoaded = false;

  static const Duration _autoScrollDuration = Duration(seconds: 4);
  static const Duration _autoScrollRestartDelay = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _loadLocalReadNotificationIds();
    _loadUserProfile();
    _loadNearbyBarbershops();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryBloc>().add(const GetAllCategoriesEvent());
      context.read<ServiceBloc>().add(const GetAllServicesEvent());
      context.read<UserBookingBloc>().add(const GetUserBookingsEvent());
    });
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_full_name') ?? '';
    final imagePath = prefs.getString('profile_image_path');
    if (!mounted) return;
    setState(() {
      _userName = name;
      _userImagePath = imagePath;
    });
  }

  Future<void> _loadNearbyBarbershops() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      final useCase = getIt<GetAllBarberShopServicesUseCase>();
      final result = await useCase(BarberShopServiceQuery(
        serviceId: '',
        lat: position.latitude,
        lng: position.longitude,
        radiusKm: 50,
      ));
      result.fold(
        (_) {},
        (shops) {
          shops.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
          if (!mounted) return;
          setState(() {
            _nearbyShops = shops.take(10).toList();
            _nearbyLoaded = true;
          });
        },
      );
    } catch (_) {}
  }


  void _openProfileDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Profile',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final pageNav = Navigator.of(this.context);
        final slideAnimation = Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

        return SlideTransition(
          position: slideAnimation,
          child: Align(
            alignment: Alignment.centerLeft,
            child: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, themeState) {
                final isDark = themeState.isDark;
                final bgColor = isDark ? AppColors.containerDark : AppColors.containerLight;
                final textColor = isDark ? Colors.white : Colors.black;
                return Material(
              color: bgColor,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.78,
                height: double.infinity,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile header
                      Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30.r,
                              backgroundColor: AppColors.yellow.withValues(alpha: 0.2),
                              backgroundImage: _userImagePath != null && _userImagePath!.isNotEmpty
                                  ? FileImage(File(_userImagePath!))
                                  : null,
                              child: _userImagePath == null || _userImagePath!.isEmpty
                                  ? Icon(Icons.person, size: 30.r, color: AppColors.yellow)
                                  : null,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userName.isNotEmpty ? _userName : 'profil'.tr(),
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      pageNav.push(
                                        MaterialPageRoute(builder: (_) => EditProfilePage(
                                          currentName: _userName,
                                          currentPhoneNumber: '',
                                        )),
                                      ).then((_) => _loadUserProfile());
                                    },
                                    child: Text(
                                      'profilni_tahrirlash'.tr(),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: AppColors.yellow,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Current date
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16.sp,
                                color: isDark ? Colors.grey[400] : Colors.grey[600]),
                            SizedBox(width: 8.w),
                            Text(
                              DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[300]),
                      // Menu items
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          children: [
                            // Theme toggle
                            BlocBuilder<ThemeBloc, ThemeState>(
                              builder: (context, state) {
                                return ListTile(
                                  leading: Icon(
                                    state.isDark ? Icons.dark_mode : Icons.light_mode,
                                    color: AppColors.yellow,
                                  ),
                                  title: Text(
                                    'mavzu'.tr(),
                                    style: TextStyle(color: textColor),
                                  ),
                                  trailing: Switch(
                                    value: state.isDark,
                                    activeColor: AppColors.yellow,
                                    onChanged: (_) {
                                      context.read<ThemeBloc>().add(ToggleTheme());
                                    },
                                  ),
                                );
                              },
                            ),
                            // Cards
                            ListTile(
                              leading: Icon(Icons.credit_card, color: AppColors.yellow),
                              title: Text('kartalar'.tr(), style: TextStyle(color: textColor)),
                              onTap: () {
                                Navigator.pop(context);
                                pageNav.push(MaterialPageRoute(builder: (_) => const CardsPage()));
                              },
                            ),
                            // Contact
                            ListTile(
                              leading: Icon(Icons.support_agent, color: AppColors.yellow),
                              title: Text('aloqa'.tr(), style: TextStyle(color: textColor)),
                              onTap: () {
                                Navigator.pop(context);
                                pageNav.push(MaterialPageRoute(builder: (_) => const ContactPage()));
                              },
                            ),
                            // Language
                            ListTile(
                              leading: Icon(Icons.language, color: AppColors.yellow),
                              title: Text('til'.tr(), style: TextStyle(color: textColor)),
                              trailing: Text(
                                context.locale.languageCode.toUpperCase(),
                                style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                _showLanguageDialog();
                              },
                            ),
                            // Share app
                            ListTile(
                              leading: Icon(Icons.share, color: AppColors.yellow),
                              title: Text('ulashish'.tr(), style: TextStyle(color: textColor)),
                              onTap: () {
                                Navigator.pop(context);
                                SharePlus.instance.share(
                                  ShareParams(text: 'https://play.google.com/store/apps/details?id=com.barbros.user'),
                                );
                              },
                            ),
                            // About app
                            ListTile(
                              leading: Icon(Icons.info_outline, color: AppColors.yellow),
                              title: Text('ilova_haqida'.tr(), style: TextStyle(color: textColor)),
                              onTap: () {
                                Navigator.pop(context);
                                pageNav.push(MaterialPageRoute(builder: (_) => const AboutAppPage()));
                              },
                            ),
                          ],
                        ),
                      ),
                      // Logout
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: const LogoutButtonWidget(),
                      ),
                    ],
                  ),
                ),
              ),
              );
              },
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('til'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("O'zbekcha"),
                trailing: context.locale.languageCode == 'uz' ? Icon(Icons.check, color: AppColors.yellow) : null,
                onTap: () {
                  context.setLocale(const Locale('uz'));
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('Русский'),
                trailing: context.locale.languageCode == 'ru' ? Icon(Icons.check, color: AppColors.yellow) : null,
                onTap: () {
                  context.setLocale(const Locale('ru'));
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('English'),
                trailing: context.locale.languageCode == 'en' ? Icon(Icons.check, color: AppColors.yellow) : null,
                onTap: () {
                  context.setLocale(const Locale('en'));
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadLocalReadNotificationIds() async {
    final storage = getIt<LocalStorage>();
    final ids = await storage.getNotificationsReadIds();
    if (!mounted) return;
    setState(() {
      _locallyReadNotificationIds = ids.toSet();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(_autoScrollDuration, (timer) {
      if (_promoPageController.hasClients && _promoPageCount > 1) {
        final nextPage = (_currentPage + 1) % _promoPageCount;
        _promoPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _scheduleAutoScrollRestart() {
    _autoScrollRestartTimer?.cancel();
    _autoScrollRestartTimer = Timer(_autoScrollRestartDelay, _startAutoScroll);
  }

  List<Category> _filterByType(List<Category> categories, String type) {
    return categories
        .where((c) => c.categoryType == type && !c.isDeleted)
        .toList();
  }

  String _resolveBookingImageUrl(String img) {
    if (img.isEmpty) return '';
    return img.startsWith('http') ? img : '${Constants.imageBaseUrl}$img';
  }

  String _formatRating(String avgRating) {
    final val = double.tryParse(avgRating);
    if (val == null || val == 0) return '0.0';
    return val.toStringAsFixed(1);
  }

  String _formatBookingDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return date;
    }
  }

  String _formatBookingTimeRange(String time, int durationMinutes) {
    try {
      String cleaned = time.trim();
      if (cleaned.contains('T')) {
        cleaned = cleaned.split('T').last;
      }
      if (cleaned.contains(' ')) {
        cleaned = cleaned.split(' ').first;
      }
      final parts = cleaned.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final start = TimeOfDay(hour: hour, minute: minute);
      final endMinutes = hour * 60 + minute + durationMinutes;
      final end = TimeOfDay(hour: (endMinutes ~/ 60) % 24, minute: endMinutes % 60);
      String fmt(TimeOfDay t) =>
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      return '${fmt(start)} - ${fmt(end)}';
    } catch (_) {
      return time;
    }
  }

  DateTime? _parseBookingDateTime(UserBooking b) {
    try {
      final dt = DateTime.parse(b.date);
      String cleaned = b.time.trim();
      if (cleaned.contains('T')) cleaned = cleaned.split('T').last;
      if (cleaned.contains(' ')) cleaned = cleaned.split(' ').first;
      final parts = cleaned.split(':');
      return DateTime(dt.year, dt.month, dt.day,
          int.parse(parts[0]), int.parse(parts[1]));
    } catch (_) {
      return null;
    }
  }

  Widget _buildRecentBarbershops() {
    return BlocBuilder<UserBookingBloc, UserBookingState>(
      builder: (context, state) {
        if (state is! UserBookingLoaded) return const SizedBox.shrink();
        final now = DateTime.now();
        // Sort all bookings by closest to current date/time
        final sorted = List<UserBooking>.from(state.allBookings)
          ..sort((a, b) {
            final dtA = _parseBookingDateTime(a);
            final dtB = _parseBookingDateTime(b);
            if (dtA == null && dtB == null) return 0;
            if (dtA == null) return 1;
            if (dtB == null) return -1;
            final diffA = dtA.difference(now).abs();
            final diffB = dtB.difference(now).abs();
            // Prefer upcoming over past
            final aIsUpcoming = dtA.isAfter(now);
            final bIsUpcoming = dtB.isAfter(now);
            if (aIsUpcoming && !bIsUpcoming) return -1;
            if (!aIsUpcoming && bIsUpcoming) return 1;
            return diffA.compareTo(diffB);
          });
        if (sorted.isEmpty) return const SizedBox.shrink();
        final last3 = sorted.take(3).toList();

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardColor = isDark ? AppColors.containerDark : AppColors.containerLight;
        final borderColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
        final textColor = isDark ? Colors.white : Colors.black;
        final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'oxirgi_buyurtmalar'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 110.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: last3.length,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  final booking = last3[index];
                  final barberImg = _resolveBookingImageUrl(booking.barber.img);
                  final rating = _formatRating(booking.barberShop.avgRating);
                  final date = _formatBookingDate(booking.date);
                  final timeRange = _formatBookingTimeRange(
                    booking.time,
                    booking.service.durationMinutes,
                  );

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BarbersPage(serviceId: booking.serviceId),
                        ),
                      );
                    },
                    child: Container(
                    width: 280.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: borderColor),

                    ),
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22.r,
                              backgroundColor: AppColors.yellow.withValues(alpha: 0.2),
                              backgroundImage: barberImg.isNotEmpty
                                  ? NetworkImage(barberImg)
                                  : null,
                              child: barberImg.isEmpty
                                  ? Icon(Icons.person, size: 22.r, color: AppColors.yellow)
                                  : null,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.barber.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.sp,
                                      color: textColor,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    booking.service.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: subtextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 14.sp, color: AppColors.yellow),
                                SizedBox(width: 2.w),
                                Text(
                                  rating,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14.sp, color: subtextColor),
                            SizedBox(width: 6.w),
                            Text(
                              date,
                              style: TextStyle(fontSize: 12.sp, color: subtextColor),
                            ),
                            SizedBox(width: 16.w),
                            Icon(Icons.access_time, size: 14.sp, color: subtextColor),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                timeRange,
                                style: TextStyle(fontSize: 12.sp, color: subtextColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                                      ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNearbyBarbershops() {
    if (!_nearbyLoaded || _nearbyShops.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.containerDark : AppColors.containerLight;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.w, top: 20.h, right: 16.w, bottom: 12.h),
          child: Text(
            'yaqin_sartaroshxonalar'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
        ),
        SizedBox(
          height: 220.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _nearbyShops.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final shop = _nearbyShops[index];
              final imageUrl = shop.shopImage.isNotEmpty
                  ? (shop.shopImage.startsWith('http')
                      ? shop.shopImage
                      : '${Constants.imageBaseUrl}${shop.shopImage}')
                  : '';
              final rating = _formatRating(shop.avgRating);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BarbershopDetailPage(
                        barbershop: Barbershop(
                          id: shop.barberShopId,
                          name: shop.shopName,
                          location: shop.shopLocation,
                          distance: shop.distanceKm,
                          rating: double.tryParse(shop.avgRating) ?? 0,
                          imageUrl: imageUrl,
                          price: shop.price,
                        ),
                      ),
                    ),
                  );
                },
                child: Material(
                  color: cardColor,
                  elevation: 4,
                  shadowColor: isDark ? Colors.black54 : Colors.black26,
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                  width: 180.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                        child: SizedBox(
                          height: 110.h,
                          width: double.infinity,
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    child: Icon(Icons.store, size: 40.r, color: Colors.grey),
                                  ),
                                )
                              : Container(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  child: Icon(Icons.store, size: 40.r, color: Colors.grey),
                                ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shop.shopName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                                color: textColor,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 12.sp, color: subtextColor),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    shop.shopLocation,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 11.sp, color: subtextColor),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.near_me, size: 12.sp, color: AppColors.yellow),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '${shop.distanceKm.toStringAsFixed(1)} km',
                                      style: TextStyle(fontSize: 11.sp, color: subtextColor),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, size: 12.sp, color: AppColors.yellow),
                                    SizedBox(width: 2.w),
                                    Text(
                                      rating,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlight = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 1200),
      direction: ShimmerDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Last bookings shimmer ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  height: 110.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    separatorBuilder: (_, __) => SizedBox(width: 12.w),
                    itemBuilder: (_, __) => Container(
                      width: 280.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          // --- Promo card shimmer ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 180.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          // --- Men's section shimmer ---
          _buildSectionTitleShimmer(),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Wrap(
              spacing: 16.w,
              runSpacing: 12.h,
              children: List.generate(4, (_) => _buildSkeletonCategoryItem()),
            ),
          ),
          SizedBox(height: 24.h),
          // --- Women's section shimmer ---
          _buildSectionTitleShimmer(),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Wrap(
              spacing: 16.w,
              runSpacing: 12.h,
              children: List.generate(4, (_) => _buildSkeletonCategoryItem()),
            ),
          ),
          SizedBox(height: 24.h),
          // --- Nearby barbershops shimmer ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 180.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  height: 220.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    separatorBuilder: (_, __) => SizedBox(width: 12.w),
                    itemBuilder: (_, __) => Container(
                      width: 180.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 110.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16.r),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 120.w,
                                  height: 14.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Container(
                                  width: 90.w,
                                  height: 10.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Container(
                                  width: 60.w,
                                  height: 10.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildSectionTitleShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 180.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          Container(
            width: 50.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoSection() {
    return BlocBuilder<ServiceBloc, ServiceState>(
      builder: (context, state) {
        if (state is ServiceLoading || state is ServiceInitial) {
          return _buildPromoLoading();
        }
        final services = _resolvePromoServices(state);
        final promoServices = services.take(5).toList();
        if (promoServices.isEmpty) {
          if (_promoPageCount != 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _promoPageCount = 0;
                _currentPage = 0;
              });
            });
          }
          return const SizedBox.shrink();
        }
        if (_promoPageCount != promoServices.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _promoPageCount = promoServices.length;
              if (_currentPage >= _promoPageCount) {
                _currentPage = 0;
              }
            });
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180.h,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification) {
                    _stopAutoScroll();
                  } else if (notification is ScrollEndNotification) {
                    _scheduleAutoScrollRestart();
                  } else if (notification is UserScrollNotification &&
                      notification.direction == ScrollDirection.idle) {
                    _scheduleAutoScrollRestart();
                  }
                  return false;
                },
                child: PageView(
                  controller: _promoPageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: promoServices
                      .map(
                        (service) => PromoCard(
                          title: service.name,
                          subtitle: service.description,
                          imageUrl: _resolveServiceImageUrl(service),
                          onTap: () => _openBarbers(context, service.id),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPromoLoading() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Shimmer.fromColors(
            baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
            period: const Duration(milliseconds: 1100),
            child: Container(
              height: 180.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: index == 0 ? 24.w : 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Service> _resolvePromoServices(ServiceState state) {
    if (state is ServiceLoaded) {
      return state.services.where((service) => !service.isDeleted).toList();
    }
    return const [];
  }

  String _resolveServiceImageUrl(Service service) {
    if (service.serviceImages.isNotEmpty) {
      return service.serviceImages.first;
    }
    return service.image;
  }

  void _openBarbers(BuildContext context, String serviceId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarbersPage(serviceId: serviceId),
      ),
    );
  }

  Widget _buildSkeletonCategoryItem() {
    return SizedBox(
      width: 73.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 73.w,
            height: 73.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: 60.w,
            height: 10.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            width: 40.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _autoScrollRestartTimer?.cancel();
    _promoPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leadingWidth: 56.w,
        leading: GestureDetector(
          onTap: _openProfileDrawer,
          child: Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: CircleAvatar(
              radius: 18.r,
              backgroundColor: AppColors.yellow.withValues(alpha: 0.2),
              backgroundImage: _userImagePath != null && _userImagePath!.isNotEmpty
                  ? FileImage(File(_userImagePath!))
                  : null,
              child: _userImagePath == null || _userImagePath!.isEmpty
                  ? Icon(Icons.person, size: 20.r, color: AppColors.yellow)
                  : null,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _userName.isNotEmpty ? _userName : 'app_name_styleup'.tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            Text(
              DateFormat('EEEE, dd MMM').format(DateTime.now()),
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              int unreadCount = 0;
              if (state is NotificationLoaded) {
                unreadCount = state.items
                    .where((item) =>
                        !item.isRead &&
                        !_locallyReadNotificationIds.contains(item.id))
                    .length;
              }
              final showBadge = unreadCount > 0;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton.outlined(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsPage(),
                        ),
                      ).then((_) {
                        _loadLocalReadNotificationIds();
                        context
                            .read<NotificationBloc>()
                            .add(const GetMyNotificationsEvent());
                      });
                    },
                    icon: const Icon(Icons.notifications_none),
                  ),
                  if (showBadge)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          SizedBox(
            width: 16.w,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoaded || state is CategoryError) {
                  _cachedState = state;
                }

                final displayState = _cachedState ?? state;

                if (displayState is CategoryLoading) {
                  return _buildLoadingSkeleton();
                } else if (displayState is CategoryError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPromoSection(),
                      Padding(
                        padding: EdgeInsets.all(32.r),
                        child: Center(
                          child: Column(
                            children: [
                              Text(displayState.message),
                              SizedBox(height: 8.h),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _cachedState = null;
                                  });
                                  context.read<CategoryBloc>().add(
                                    const GetAllCategoriesEvent(),
                                  );
                                },
                                child: Text("qayta_urinish".tr()),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (displayState is CategoryLoaded) {
                  final manCategories =
                  _filterByType(displayState.categories, 'man');
                  final womanCategories =
                  _filterByType(displayState.categories, 'woman');

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: _buildRecentBarbershops(),
                      ),
                      _buildPromoSection(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "erkaklar_uchun_xizmatlar".tr(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp),
                            ),
                            TextButton(
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ManCategoriesPage(),
                                    ),
                                  );
                                },
                                child: Text("seeall".tr()))
                          ],
                        ),
                      ),
                      manCategories.isEmpty
                          ? Padding(
                        padding: EdgeInsets.all(32.r),
                        child: Center(
                          child: Text(
                              "hech_qanday_kategoriyalar_topilmadi"
                                  .tr()),
                        ),
                      )
                          : Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 16.w),
                        child: Wrap(
                          spacing: 16.w,
                          runSpacing: 12.h,
                          children: manCategories.map((category) {
                            return ServiceCategory(
                              imageUrl: category.img,
                              label: category.name,
                              categoryId: category.id,
                              categoryType: category.categoryType,
                            );
                          }).toList(),
                        ),
                      ),
                      // Women's categories
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "ayollar_uchun_xizmatlar".tr(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp),
                            ),
                            TextButton(
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const WomanCategoriesPage(),
                                    ),
                                  );
                                },
                                child: Text("seeall".tr()))
                          ],
                        ),
                      ),
                      womanCategories.isEmpty
                          ? Padding(
                        padding: EdgeInsets.all(32.r),
                        child: Center(
                          child: Text(
                              "hech_qanday_kategoriyalar_topilmadi"
                                  .tr()),
                        ),
                      )
                          : Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 16.w),
                        child: Wrap(
                          spacing: 16.w,
                          runSpacing: 12.h,
                          children: womanCategories.map((category) {
                            return ServiceCategory(
                              imageUrl: category.img,
                              label: category.name,
                              categoryId: category.id,
                              categoryType: category.categoryType,
                            );
                          }).toList(),
                        ),
                      ),
                      // Nearby barbershops
                      _buildNearbyBarbershops(),
                      SizedBox(height: 20.h),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}