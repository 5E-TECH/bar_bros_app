import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:bar_bros_user/core/di/ingector.dart';
import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/features/barber_shop/domain/entities/barber_shop_query.dart';
import 'package:bar_bros_user/features/barber_shop/domain/usecases/get_barber_shops_usecase.dart';
import 'package:bar_bros_user/features/barber_shop_services/domain/entities/barber_shop_service_query.dart';
import 'package:bar_bros_user/features/barber_shop_services/domain/usecases/get_all_barber_shop_services_usecase.dart';
import 'package:bar_bros_user/features/user_booking/domain/entities/user_booking.dart';
import 'package:bar_bros_user/features/user_booking/presentation/bloc/user_booking_bloc.dart';
import 'package:bar_bros_user/features/user_booking/presentation/bloc/user_booking_event.dart';
import 'package:bar_bros_user/features/user_booking/presentation/bloc/user_booking_state.dart';
import 'package:bar_bros_user/pages/tarix/custom_tab_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _currentTabIndex = 0;
  int _previousTabIndex = 0;
  late final UserBookingBloc _bookingBloc;
  final Map<String, String> _distanceByShopId = {};
  bool _distanceLoading = false;
  bool _distanceLoaded = false;
  double? _lat;
  double? _lng;
  static const double _defaultRadiusKm = 10;
  static const double _defaultDistance = 0;
  bool _pageVisible = false;

  @override
  void initState() {
    super.initState();
    _bookingBloc = getIt<UserBookingBloc>()..add(const GetUserBookingsEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _pageVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _bookingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bookingBloc,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(
            "Orders".tr(),
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
        ),
        body: AnimatedOpacity(
          opacity: _pageVisible ? 1 : 0,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
          child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: CustomTabBar(
                tabs: ["Kelgusi".tr(), "Tarix".tr()],
                onTabChanged: (index) {
                  setState(() {
                    _previousTabIndex = _currentTabIndex;
                    _currentTabIndex = index;
                  });
                },
              ),
            ),
            Expanded(
              child: BlocConsumer<UserBookingBloc, UserBookingState>(
                listener: (context, state) {
                  if (state is UserBookingLoaded) {
                    _loadDistanceMap(state.allBookings);
                  }
                },
                builder: (context, state) {
                  if (state is UserBookingLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColors.yellow),
                    );
                  }
                  if (state is UserBookingError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                    );
                  }
                  if (state is UserBookingLoaded) {
                    final bookings = _currentTabIndex == 0
                        ? state.upcomingBookings
                        : state.historyBookings;
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: Container(
                        key: ValueKey<int>(_currentTabIndex),
                        child: bookings.isEmpty
                            ? _buildEmptyTab(context)
                            : _buildBookingsList(context, bookings),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.primaryLight : AppColors.primaryDark;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 80.r, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            "Bandlovlar yo'q!".tr(),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Hech qanaga bandlov topilmadi.".tr(),
            style: TextStyle(fontSize: 14.sp, color: subtitleColor),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(BuildContext context, List<UserBooking> bookings) {
    final sorted = List<UserBooking>.from(bookings)
      ..sort((a, b) {
        final orderA = _statusOrder(_effectiveStatus(a));
        final orderB = _statusOrder(_effectiveStatus(b));
        if (orderA != orderB) {
          return orderA.compareTo(orderB);
        }
        final dateA = _parseBookingDateTime(a.date, a.time);
        final dateB = _parseBookingDateTime(b.date, b.time);
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateA.compareTo(dateB);
      });
    final children = <Widget>[];
    String? lastStatus;
    for (final booking in sorted) {
      final statusKey = _effectiveStatus(booking);
      if (lastStatus != null && lastStatus != statusKey) {
        children.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Divider(
              color: Colors.grey.withValues(alpha: 0.3),
              height: 1,
            ),
          ),
        );
      }
      children.add(
        Padding(
          padding: EdgeInsets.only(top: 12.h),
          child: GestureDetector(
            onTap: () => _showBookingDetailsSheet(context, booking),
            child: _buildBookingCardFromModel(context, booking),
          ),
        ),
      );
      lastStatus = statusKey;
    }
    return ListView(padding: EdgeInsets.all(16.r), children: children);
  }

  Widget _buildBookingCardFromModel(BuildContext context, UserBooking booking) {
    final imageUrl = _resolveImageUrl(
      booking.barber.img.isNotEmpty
          ? booking.barber.img
          : booking.barberShop.img,
    );
    final dateText = _formatBookingDate(booking.date, context);
    final timeText = _formatBookingTimeRange(
      booking.time,
      booking.service.durationMinutes,
    );
    final effectiveStatus = _effectiveStatus(booking);
    final statusText = _formatStatus(effectiveStatus);
    final statusColor = _resolveStatusColor(effectiveStatus);
    final distance = _distanceByShopId[booking.barberShopId] ?? '-';
    return _buildBookingCard(
      context: context,
      status: statusText,
      statusColor: statusColor,
      name: booking.barber.fullName,
      date: dateText,
      time: timeText,
      location: booking.barberShop.location,
      distance: distance,
      imageUrl: imageUrl,
      rating: booking.barber.avgReyting,
    );
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Kutilmoqda'.tr();
      case 'confirmed':
        return 'Qabul qilingan'.tr();
      case 'in_progress':
        return 'Jarayonda'.tr();
      case 'completed':
        return 'Bajarildi'.tr();
      case 'cancelled':
        return 'Bekor qilindi'.tr();
      case 'expired':
        return 'Tugagan'.tr();
      default:
        return status;
    }
  }

  String _formatBookingDate(String date, BuildContext context) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('dd MMM', context.locale.toString()).format(parsed);
    } catch (_) {
      return date;
    }
  }

  String _formatBookingTimeRange(String time, int durationMinutes) {
    final parts = time.split(':');
    if (parts.length < 2) return time;
    final startHour = int.tryParse(parts[0]) ?? 0;
    final startMinute = int.tryParse(parts[1]) ?? 0;
    final startTotal = startHour * 60 + startMinute;
    final endTotal = startTotal + durationMinutes;
    final endHour = (endTotal ~/ 60) % 24;
    final endMinute = endTotal % 60;
    final start =
        '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
    final end =
        '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  Color _resolveStatusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'completed' ||
        normalized == 'cancelled' ||
        normalized == 'expired') {
      return Colors.red;
    }
    if (normalized == 'in_progress') {
      return AppColors.yellow;
    }
    if (normalized == 'confirmed') {
      return Colors.green;
    }
    if (normalized == 'pending') {
      return Colors.blue;
    }
    return Colors.grey;
  }

  int _statusOrder(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'confirmed':
        return 1;
      case 'in_progress':
        return 2;
      case 'completed':
        return 3;
      case 'cancelled':
        return 4;
      case 'expired':
        return 5;
      default:
        return 6;
    }
  }

  String _effectiveStatus(UserBooking booking) {
    final status = booking.status.toLowerCase();
    if (status == 'completed' || status == 'cancelled') {
      return status;
    }
    final window = _bookingWindow(booking);
    if (window != null) {
      final now = DateTime.now();
      if (now.isAfter(window.start) && now.isBefore(window.end)) {
        return 'in_progress';
      }
      if (now.isAfter(window.end) && status == 'pending') {
        return 'expired';
      }
    }
    return status;
  }

  _BookingWindow? _bookingWindow(UserBooking booking) {
    final start = _parseBookingDateTime(booking.date, booking.time);
    if (start == null) return null;
    final duration = booking.service.durationMinutes;
    final end = start.add(Duration(minutes: duration));
    return _BookingWindow(start: start, end: end);
  }

  DateTime? _parseBookingDateTime(String date, String time) {
    final normalizedDate = date.trim();
    final normalizedTime = time.trim();
    if (normalizedDate.isEmpty && normalizedTime.isEmpty) return null;
    final looksLikeDateTime = normalizedTime.contains('-') &&
        (normalizedTime.contains('T') || normalizedTime.contains(' '));
    if (looksLikeDateTime) {
      final normalized = normalizedTime.contains(' ')
          ? normalizedTime.replaceFirst(' ', 'T')
          : normalizedTime;
      try {
        return DateTime.parse(normalized);
      } catch (_) {
        return null;
      }
    }
    if (normalizedDate.isEmpty || normalizedTime.isEmpty) return null;
    final formattedTime = normalizedTime.contains('T')
        ? normalizedTime.split('T').last
        : normalizedTime.split(' ').first;
    final value = '${normalizedDate}T${formattedTime}';
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  String _resolveImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return '${Constants.imageBaseUrl}$url';
  }

  String _formatRating(String rating) {
    final value = double.tryParse(rating) ?? 0.0;
    return value.toStringAsFixed(1);
  }

  void _showBookingDetailsSheet(BuildContext context, UserBooking booking) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final imageUrl = _resolveImageUrl(
      booking.barber.img.isNotEmpty
          ? booking.barber.img
          : booking.barberShop.img,
    );
    final effectiveStatus = _effectiveStatus(booking);
    final statusText = _formatStatus(effectiveStatus);
    final statusColor = _resolveStatusColor(effectiveStatus);
    final dateText = _formatBookingDate(booking.date, context);
    final timeText = _formatBookingTimeRange(
      booking.time,
      booking.service.durationMinutes,
    );
    final distance = _distanceByShopId[booking.barberShopId] ?? '-';

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.containerDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[600]
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.grey[800] : Colors.grey[300],
                        image: imageUrl.isEmpty
                            ? null
                            : DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                      ),
                      child: imageUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              color: isDark ? Colors.grey[600] : Colors.grey[500],
                              size: 28.sp,
                            )
                          : null,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  booking.barber.fullName,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                _formatRating(booking.barber.avgReyting),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.star,
                                color: AppColors.yellow,
                                size: 16.sp,
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                color: subtitleColor,
                                size: 14.sp,
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  booking.barber.phoneNumber.isEmpty
                                      ? '-'
                                      : booking.barber.phoneNumber,
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: 12.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (booking.barber.bio.isNotEmpty) ...[
                            SizedBox(height: 6.h),
                            Text(
                              booking.barber.bio,
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 12.sp,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey[800]!.withValues(alpha: 0.5)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.circle,
                        iconColor: statusColor,
                        label: "Holat".tr(),
                        value: statusText,
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                      ),
                      SizedBox(height: 10.h),
                      _buildInfoRow(
                        icon: Icons.content_cut,
                        label: "Xizmat".tr(),
                        value: booking.service.name,
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                      ),
                      SizedBox(height: 10.h),
                      _buildInfoRow(
                        icon: Icons.calendar_today,
                        label: "Sana".tr(),
                        value: dateText,
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                      ),
                      SizedBox(height: 10.h),
                      _buildInfoRow(
                        icon: Icons.access_time,
                        label: "Vaqt".tr(),
                        value: timeText,
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                      ),
                      SizedBox(height: 10.h),
                      _buildInfoRow(
                        icon: Icons.location_on,
                        label: "Manzil".tr(),
                        value: booking.barberShop.location,
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                      ),
                      SizedBox(height: 10.h),
                      _buildInfoRow(
                        icon: Icons.navigation,
                        label: "Masofa".tr(),
                        value: '$distance km',
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                      ),
                      SizedBox(height: 10.h),
                      _buildInfoRow(
                        icon: Icons.payments,
                        label: "To'lov".tr(),
                        value: booking.paymentModel,
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    Color? iconColor,
    required String label,
    required String value,
    required Color textColor,
    required Color? subtitleColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: iconColor ?? subtitleColor),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: subtitleColor,
          ),
        ),
        Spacer(),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _loadDistanceMap(List<UserBooking> bookings) async {
    if (_distanceLoaded || _distanceLoading) return;
    if (bookings.isEmpty) return;
    setState(() {
      _distanceLoading = true;
    });
    await _ensureLocation();
    final serviceIds = bookings.map((booking) => booking.serviceId).toSet();
    final useCase = getIt<GetAllBarberShopServicesUseCase>();

    for (final serviceId in serviceIds) {
      final result = await useCase(
        BarberShopServiceQuery(
          serviceId: serviceId,
          distance: _defaultDistance,
          avgRating: 0,
          radiusKm: _defaultRadiusKm,
          lat: _lat ?? 0,
          lng: _lng ?? 0,
        ),
      );
      result.fold((_) {}, (services) {
        for (final service in services) {
          _distanceByShopId[service.barberShopId] = service.distanceKm
              .toStringAsFixed(2);
        }
      });
    }
    if (!mounted) return;
    setState(() {
      _distanceLoading = false;
      _distanceLoaded = true;
    });
  }

  Future<void> _ensureLocation() async {
    if (_lat != null && _lng != null) return;
    final useCase = getIt<GetBarberShopsUseCase>();
    final result = await useCase(const BarberShopQuery(limit: 100, page: 1));
    result.fold(
      (_) {
        _lat = 0;
        _lng = 0;
      },
      (shops) {
        for (final shop in shops) {
          if (!shop.isDeleted) {
            _lat = shop.latitude;
            _lng = shop.longitude;
            break;
          }
        }
        _lat ??= 0;
        _lng ??= 0;
      },
    );
  }

  Widget _buildBookingCard({
    required BuildContext context,
    required String status,
    required Color statusColor,
    required String name,
    required String date,
    required String time,
    required String location,
    required String distance,
    required String imageUrl,
    required String rating,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? AppColors.containerDark
        : AppColors.containerLight;
    final textColor = isDark ? AppColors.primaryLight : AppColors.primaryDark;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isDark ? Colors.grey[700] : Colors.grey[200];

    return Material(
      color: cardColor,
      elevation: 2,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: borderColor!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 16.r,
                      height: 16.r,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      status,
                      style: TextStyle(fontSize: 14.sp, color: subtitleColor),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      _formatRating(rating),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.star, size: 16.r, color: AppColors.yellow),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  backgroundImage: imageUrl.isEmpty
                      ? null
                      : NetworkImage(imageUrl),
                  child: imageUrl.isEmpty
                      ? Icon(Icons.person, color: subtitleColor)
                      : null,
                ),
                SizedBox(width: 12.w),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              '$date  $time',
              style: TextStyle(fontSize: 14.sp, color: subtitleColor),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.navigation, size: 16.r, color: subtitleColor),
                    SizedBox(width: 4.w),
                    Text(
                      tr('distance_from_you', namedArgs: {'distance': distance}),
                      style: TextStyle(fontSize: 14.sp, color: subtitleColor),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingWindow {
  final DateTime start;
  final DateTime end;

  const _BookingWindow({required this.start, required this.end});
}
