import 'dart:math';

import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:bar_bros_user/core/di/ingector.dart';
import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/features/barber_shop/domain/entities/barber_shop_item.dart';
import 'package:bar_bros_user/features/barber_shop/domain/entities/barber_shop_query.dart';
import 'package:bar_bros_user/features/barber_shop/domain/usecases/get_barber_shops_usecase.dart';
import 'package:bar_bros_user/features/user_booking/presentation/bloc/user_booking_bloc.dart';
import 'package:bar_bros_user/features/user_booking/presentation/bloc/user_booking_state.dart';
import 'package:bar_bros_user/models/barbershop.dart';
import 'package:bar_bros_user/pages/barbershop_detail.dart';
import 'package:bar_bros_user/pages/berbers_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _NearbyShop {
  final BarberShopItem shop;
  final double distanceKm;
  _NearbyShop(this.shop, this.distanceKm);
}

class _SearchPageState extends State<SearchPage> {
  String _userName = '';
  List<_NearbyShop> _nearbyShops = [];
  bool _nearbyLoaded = false;

  @override
  void initState() {
    super.initState();
    debugPrint('===== SearchPage initState called =====');
    _loadUserProfile();
    _loadNearbyBarbershops();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userName = [
        prefs.getString('profile_first_name') ?? '',
        prefs.getString('profile_last_name') ?? '',
      ].where((v) => v.trim().isNotEmpty).join(' ');
    });
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  Future<Position?> _getPosition() async {
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;
      return await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadNearbyBarbershops() async {
    if (_nearbyLoaded) return;
    _nearbyLoaded = true;
    try {
      if (!mounted) return;
      final useCase = getIt<GetBarberShopsUseCase>();
      final positionFuture = _getPosition();
      final result = await useCase(const BarberShopQuery(limit: 50, page: 1));
      final position = await positionFuture;

      result.fold((_) {}, (shops) {
        final nearby = shops.map((shop) {
          final dist = position != null
              ? _calculateDistance(
                  position.latitude, position.longitude,
                  shop.latitude, shop.longitude,
                )
              : 0.0;
          return _NearbyShop(shop, dist);
        }).toList();
        if (position != null) {
          nearby.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        }
        if (mounted) setState(() => _nearbyShops = nearby);
      });
    } catch (_) {}
  }

  String _resolveImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return '${Constants.imageBaseUrl}$url';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return DateFormat('EEEE, MMMM d').format(now);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final cardColor = isDark ? Colors.grey[900]! : Colors.grey[100]!;
    final searchBorderColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Header
                Text(
                  _userName.isNotEmpty
                      ? '${"salom".tr()}, $_userName 👋'
                      : '${"salom".tr()} 👋',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getFormattedDate(),
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),

                // Search Bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: searchBorderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: subtextColor),
                      const SizedBox(width: 12),
                      Text(
                        'sartaroshlarni_qidirish'.tr(),
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Latest Visit Section
                _buildLatestVisit(
                    isDark, textColor, subtextColor, cardColor),
                const SizedBox(height: 32),

                // Nearby Barbershop Section
                _buildNearbyBarbershops(
                    isDark, textColor, subtextColor, cardColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLatestVisit(
      bool isDark, Color textColor, Color subtextColor, Color cardColor) {
    return BlocBuilder<UserBookingBloc, UserBookingState>(
      builder: (context, state) {
        if (state is! UserBookingLoaded) return const SizedBox.shrink();

        final completedBookings = state.historyBookings
            .where((b) => b.status.toLowerCase() == 'completed')
            .toList()
          ..sort((a, b) {
            try {
              return DateTime.parse(b.date.trim())
                  .compareTo(DateTime.parse(a.date.trim()));
            } catch (_) {
              return 0;
            }
          });
        if (completedBookings.isEmpty) return const SizedBox.shrink();

        final booking = completedBookings.first;
        final barber = booking.barber;
        final imageUrl = _resolveImageUrl(
          barber.img.isNotEmpty ? barber.img : booking.barberShop.img,
        );
        final rating = double.tryParse(barber.avgReyting) ?? 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'oxirgi_buyurtmalar'.tr().toUpperCase(),
              style: TextStyle(
                color: subtextColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            // Latest Visit Card - same UI style
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BarbersPage(serviceId: booking.serviceId),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900]! : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Barber Avatar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: Icon(Icons.person,
                                    size: 40, color: Colors.grey[600]),
                              ),
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: Icon(Icons.person,
                                  size: 40, color: Colors.grey[600]),
                            ),
                    ),
                    const SizedBox(width: 16),

                    // Barber Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            barber.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.orange, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Book Button
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'bron_qilish'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNearbyBarbershops(
      bool isDark, Color textColor, Color subtextColor, Color cardBgColor) {
    if (_nearbyShops.isEmpty) return const SizedBox.shrink();

    final cardColor = isDark ? Colors.grey[900]! : Colors.grey[100]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'yaqin_sartaroshxonalar'.tr().toUpperCase(),
          style: TextStyle(
            color: subtextColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal scroll
        SizedBox(
          height: 280.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _nearbyShops.length,
            itemBuilder: (context, index) {
              final nearbyShop = _nearbyShops[index];
              return _buildBarbershopCard(
                nearbyShop: nearbyShop,
                isDark: isDark,
                textColor: textColor,
                subtextColor: subtextColor,
                cardColor: cardColor,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBarbershopCard({
    required _NearbyShop nearbyShop,
    required bool isDark,
    required Color textColor,
    required Color subtextColor,
    required Color cardColor,
  }) {
    final shop = nearbyShop.shop;
    final imageUrl = _resolveImageUrl(shop.img);
    final rating = double.tryParse(shop.avgRating) ?? 0.0;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BarbershopDetailPage(
              barbershop: Barbershop(
                id: shop.id,
                name: shop.name,
                location: shop.location,
                distance: nearbyShop.distanceKm,
                rating: rating,
                imageUrl: shop.img,

              ),
            ),
          ),
        );
      },
      child: Container(
        width: 200.w,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: BoxBorder.all(color: borderColor)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with rating and favorite
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          height: 140.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 140.h,
                            width: double.infinity,
                            color:
                                isDark ? Colors.grey[800] : Colors.grey[300],
                            child: Icon(Icons.store,
                                size: 60,
                                color: isDark
                                    ? Colors.grey[700]
                                    : Colors.grey[500]),
                          ),
                        )
                      : Container(
                          height: 140.h,
                          width: double.infinity,
                          color: isDark ? Colors.grey[800] : Colors.grey[300],
                          child: Icon(Icons.store,
                              size: 60,
                              color: isDark
                                  ? Colors.grey[700]
                                  : Colors.grey[500]),
                        ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star,
                            color: Colors.orange, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Info Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Open badge + status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'open'.tr().toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${nearbyShop.distanceKm.toStringAsFixed(1)} km',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Shop Name
                  Text(
                    shop.name,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: subtextColor, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          shop.location,
                          style: TextStyle(
                            color: subtextColor,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}