import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:bar_bros_user/core/di/ingector.dart';
import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/core/widgets/elevated_button_widget.dart';
import 'package:bar_bros_user/features/barbers_by_shop_service/domain/entities/barbers_by_shop_service_query.dart';
import 'package:bar_bros_user/features/barbers_by_shop_service/presentation/bloc/barbers_by_shop_service_bloc.dart';
import 'package:bar_bros_user/features/barbers_by_shop_service/presentation/bloc/barbers_by_shop_service_event.dart';
import 'package:bar_bros_user/features/barbers_by_shop_service/presentation/bloc/barbers_by_shop_service_state.dart';
import 'package:bar_bros_user/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:bar_bros_user/features/booking_availability/domain/entities/booking_availability.dart';
import 'package:bar_bros_user/features/booking_availability/domain/entities/booking_availability_query.dart';
import 'package:bar_bros_user/features/booking_availability/domain/usecases/get_booking_availability_usecase.dart';
import 'package:bar_bros_user/features/theme/bloc/theme_bloc.dart';
import 'package:bar_bros_user/models/barbershop.dart';
import 'package:bar_bros_user/models/models_ditails.dart';
import 'package:bar_bros_user/pages/chat/conversation_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BarbershopDetailPage extends StatefulWidget {
  final Barbershop barbershop;
  final String? serviceId;

  const BarbershopDetailPage({
    super.key,
    required this.barbershop,
    this.serviceId,
  });

  @override
  State<BarbershopDetailPage> createState() => _BarbershopDetailPageState();
}

class _BarbershopDetailPageState extends State<BarbershopDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isFavorite = false;
  late final BarbersByShopServiceBloc _barbersBloc;
  late final BookingBloc _bookingBloc;
  bool _hasRequestedBarbers = false;
  final Map<String, Map<String, BookingAvailability>>
      _availabilityByBarberIdDate = {};
  bool _isAvailabilityLoading = false;
  List<Master> _currentBarbers = [];
  bool _isBookingSheetOpen = false;

  // Date and time selection
  DateTime selectedDate = DateTime.now();
  String? selectedTimeSlot;

  // Generate dates for next 7 days
  List<DateTime> get availableDates {
    return List.generate(
      7,
      (index) => DateTime.now().add(Duration(days: index)),
    );
  }


  final List<Master> masters = [
    Master(
      name: 'Mirshakar',
      surname: 'Ahror',
      rating: 4.5,
      reviewCount: 120,
      imageUrl: 'assets/images/master1.jpg',
      yearsExperience: 3,
      availableTimeSlots: ['12:00', '13:00', '15:00'],
    ),
    Master(
      name: 'Abdullayev',
      surname: 'Jasur',
      rating: 4.9,
      reviewCount: 95,
      imageUrl: 'assets/images/master2.jpg',
      yearsExperience: 5,
      availableTimeSlots: ['12:00', '13:00', '14:00', '15:00'],
    ),
    Master(
      name: 'Yaxshimuratov',
      surname: 'Yaxshimurod',
      rating: 4.8,
      reviewCount: 150,
      imageUrl: 'assets/images/master3.jpg',
      yearsExperience: 4,
      availableTimeSlots: ['13:00', '14:00', '16:00', '17:00'],
    ),
  ];

  List<Master> get filteredMasters {
    if (selectedTimeSlot == null) return masters;
    return masters.where((master) {
      return master.availableTimeSlots.contains(selectedTimeSlot);
    }).toList();
  }

  void _showBookingSheet(Master master, bool isDark) {
    _isBookingSheetOpen = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        DateTime sheetSelectedDate = selectedDate;

        List<DateTime> _rangeDates() => availableDates;

        List<TimeSlot> _slotsForDate(DateTime date) {
          final availability = _availabilityForBarberDate(master.id, date);
          if (availability == null) return <TimeSlot>[];
          final filteredSlots = _filterSlotsByBusinessHours(
            _filterToThirtyMinuteSlots(availability.freeSlots),
          );
          return filteredSlots.map(_toTimeSlot).toList();
        }

        _loadAvailabilityForBarbers([master], sheetSelectedDate);

        var availableSlots = _slotsForDate(sheetSelectedDate);
        String? selectedTime = selectedTimeSlot;
        String? selectedPayment;
        if (selectedTime != null &&
            !availableSlots.any((slot) => slot.startTime == selectedTime)) {
          selectedTime = null;
        }
        return StatefulBuilder(
          builder: (context, setModalState) {
            availableSlots = _slotsForDate(sheetSelectedDate);
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
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.4),
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
                            color: Colors.grey[800],
                            image: master.imageUrl.isEmpty
                                ? null
                                : DecorationImage(
                                    image: master.imageUrl.startsWith('http')
                                        ? NetworkImage(master.imageUrl)
                                        : AssetImage(master.imageUrl)
                                            as ImageProvider,
                                    fit: BoxFit.cover,
                                    onError: (exception, stackTrace) {},
                                  ),
                          ),
                          child: master.imageUrl.isEmpty
                              ? Icon(
                                  Icons.person,
                                  color: Colors.grey[600],
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
                                  Text(
                                    '${master.name} ${master.surname}',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.star,
                                    color: AppColors.yellow,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    master.rating.toStringAsFixed(1),
                                    style: TextStyle(
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: Colors.grey,
                                    size: 14.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      widget.barbershop.phoneNumber.isEmpty
                                          ? '-'
                                          : widget.barbershop.phoneNumber,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12.sp,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (master.bio.isNotEmpty) ...[
                                SizedBox(height: 6.h),
                                Text(
                                  master.bio,
                                  style: TextStyle(
                                    color: Colors.grey,
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
                    Text(
                      "Bo'sh vaxtlar",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      height: 48.h,
                      child: Builder(
                        builder: (context) {
                          final rangeDates = _rangeDates();
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: rangeDates.length,
                            itemBuilder: (context, index) {
                              final date = rangeDates[index];
                              final now = DateTime.now();
                              final isToday =
                                  date.year == now.year &&
                                  date.month == now.month &&
                                  date.day == now.day;
                              final isSelected =
                                  sheetSelectedDate.year == date.year &&
                                  sheetSelectedDate.month == date.month &&
                                  sheetSelectedDate.day == date.day;
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    sheetSelectedDate = date;
                                    selectedTime = null;
                                  });
                                  setState(() {
                                    selectedDate = date;
                                    selectedTimeSlot = null;
                                  });
                                  _loadAvailabilityForBarbers([master], date);
                                },
                                child: Container(
                                  width: 60.w,
                                  margin: EdgeInsets.only(right: 12.w),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.yellow
                                        : isDark
                                            ? AppColors.containerDark
                                            : Colors.grey.withValues(
                                                alpha: 0.1,
                                              ),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: isSelected
                                        ? null
                                        : Border.all(
                                            color: isDark
                                                ? Colors.grey.withValues(
                                                    alpha: 0.2,
                                                  )
                                                : Colors.grey.withValues(
                                                    alpha: 0.3,
                                                  ),
                                          ),
                                  ),
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: isToday
                                            ? [
                                                Text(
                                                  'bugun'.tr(),
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : (isDark
                                                              ? Colors.white
                                                              : Colors.black),
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ]
                                            : [
                                                Text(
                                                  DateFormat('dd').format(date),
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : (isDark
                                                              ? Colors.white
                                                              : Colors.black),
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  DateFormat('MMM').format(date),
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Colors.grey,
                                                    fontSize: 10.sp,
                                                  ),
                                                ),
                                              ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      height: 48.h,
                      child: availableSlots.isEmpty
                          ? Center(
                              child: Text(
                                "Bo'sh vaqtlar topilmadi",
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.grey[400] : Colors.grey,
                                  fontSize: 12.sp,
                                ),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: availableSlots.length,
                              itemBuilder: (context, index) {
                                final slot = availableSlots[index];
                                final isSelected =
                                    selectedTime == slot.startTime;
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      selectedTime = slot.startTime;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 10.w),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.yellow
                                              .withValues(alpha: 0.15)
                                          : (isDark
                                              ? AppColors.containerDark
                                              : Colors.grey
                                                  .withValues(alpha: 0.1)),
                                      borderRadius: BorderRadius.circular(10.r),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.yellow
                                            : Colors.grey.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        tr(
                                          'time_up_to',
                                          namedArgs: {
                                            'start': slot.startTime,
                                            'end': slot.endTime,
                                          },
                                        ),
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppColors.yellow
                                              : (isDark
                                                  ? Colors.white
                                                  : Colors.black),
                                          fontSize: 12.sp,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    if (selectedTime != null) ...[
                      SizedBox(height: 12.h),
                      Text(
                        'Tanlangan vaqt: ${DateFormat('dd MMM').format(sheetSelectedDate)} '
                        '${selectedTime ?? ''}',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    SizedBox(height: 16.h),
                    Text(
                      "tolov_turini_tanlang".tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedPayment = 'payme';
                              });
                            },
                            child: Container(
                              height: 60.h,
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: selectedPayment == 'payme'
                                      ? AppColors.yellow
                                      : Colors.grey.withValues(alpha: 0.3),
                                  width: selectedPayment == 'payme' ? 2 : 1,
                                ),
                              ),
                              child: Image.asset(
                                "assets/images/Paymeuz.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedPayment = 'click';
                              });
                            },
                            child: Container(
                              height: 60.h,
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: selectedPayment == 'click'
                                      ? AppColors.yellow
                                      : Colors.grey.withValues(alpha: 0.3),
                                  width: selectedPayment == 'click' ? 2 : 1,
                                ),
                              ),
                              child: Image.asset(
                                "assets/images/Click.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedPayment = 'cash';
                              });
                            },
                            child: Container(
                              height: 60.h,
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: selectedPayment == 'cash'
                                    ? AppColors.yellow.withValues(alpha: 0.12)
                                    : (isDark
                                        ? AppColors.containerDark
                                        : Colors.grey.withValues(alpha: 0.08)),
                                border: Border.all(
                                  color: selectedPayment == 'cash'
                                      ? AppColors.yellow
                                      : Colors.grey.withValues(alpha: 0.3),
                                  width: selectedPayment == 'cash' ? 2 : 1,
                                ),
                                boxShadow: [
                                  if (!isDark)
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 28.w,
                                    height: 28.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.yellow.withValues(
                                        alpha: selectedPayment == 'cash' ? 0.2 : 0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.payments_rounded,
                                      size: 16.sp,
                                      color: AppColors.yellow,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Naqd',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButtonWidget(
                      text: "bron_qilish".tr(),
                      onPressed:
                          (selectedTime != null && selectedPayment != null)
                          ? () {
                              final formattedDate = _formatAvailabilityDate(sheetSelectedDate);
                              final formattedTime = "$selectedTime:00";
                              final paymentModel =
                                  _mapPaymentModel(selectedPayment!);
                              final orderType =
                                  _mapOrderType(selectedPayment!);

                              _bookingBloc.add(CreateBookingEvent(
                                serviceId: int.tryParse(widget.serviceId ?? '0') ?? 0,
                                barberId: int.tryParse(master.id) ?? 0,
                                barberShopId: int.tryParse(widget.barbershop.id) ?? 0,
                                date: formattedDate,
                                time: formattedTime,
                                paymentModel: paymentModel,
                                orderType: orderType,
                              ));

                              setState(() {
                                selectedTimeSlot = selectedTime;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          _isBookingSheetOpen = false;
        });
      } else {
        _isBookingSheetOpen = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    isFavorite = widget.barbershop.isFavorite;
    _barbersBloc = getIt<BarbersByShopServiceBloc>();
    _bookingBloc = getIt<BookingBloc>();
    _loadBarbersOnInit();
  }

  void _loadBarbersOnInit() {
    final serviceId = widget.serviceId;
    if (serviceId == null || serviceId.isEmpty) return;
    _hasRequestedBarbers = true;
    _barbersBloc.add(
      GetBarbersByShopServiceEvent(
        query: BarbersByShopServiceQuery(
          barberShopId: widget.barbershop.id,
          serviceId: serviceId,
        ),
      ),
    );
  }

  String _mapPaymentModel(String value) {
    switch (value) {
      case 'payme':
      case 'click':
        return 'online';
      case 'cash':
        return 'cash';
      case 'card':
        return 'card';
      default:
        return 'online';
    }
  }

  String _mapOrderType(String value) {
    switch (value) {
      case 'payme':
      case 'click':
        return 'online';
      case 'cash':
        return 'offline';
      default:
        return 'online';
    }
  }

  String _formatAvailabilityDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  TimeSlot _toTimeSlot(String startTime) {
    final parts = startTime.split(':');
    if (parts.length != 2) {
      return TimeSlot(startTime: startTime, endTime: startTime);
    }
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final totalMinutes = hour * 60 + minute + 30;
    final endHour = (totalMinutes ~/ 60) % 24;
    final endMinute = totalMinutes % 60;
    final endTime =
        '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
    return TimeSlot(startTime: startTime, endTime: endTime);
  }

  List<String> _filterToThirtyMinuteSlots(List<String> slots) {
    return slots.where((slot) {
      final parts = slot.split(':');
      if (parts.length != 2) return false;
      final minute = int.tryParse(parts[1]) ?? -1;
      return minute % 30 == 0;
    }).toList();
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }

  List<String> _filterSlotsByBusinessHours(List<String> slots) {
    final startMinutes = _timeToMinutes('08:00');
    final endMinutes = _timeToMinutes('15:30');
    return slots.where((slot) {
      final minutes = _timeToMinutes(slot);
      return minutes >= startMinutes && minutes < endMinutes;
    }).toList();
  }

  List<String> _filterExpiredSlots(DateTime date, List<String> slots) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    if (!isToday) return slots;
    final nowMinutes = now.hour * 60 + now.minute;
    return slots.where((slot) => _timeToMinutes(slot) > nowMinutes).toList();
  }

  Future<void> _loadAvailabilityForBarbers(
    List<Master> barbers,
    DateTime date,
  ) async {
    final serviceId = widget.serviceId;
    if (serviceId == null || serviceId.isEmpty) return;
    if (barbers.isEmpty) return;

    final dateKey = _formatAvailabilityDate(date);
    final missingBarbers = barbers.where((barber) {
      final cached = _availabilityByBarberIdDate[barber.id];
      return cached == null || !cached.containsKey(dateKey);
    }).toList();
    if (missingBarbers.isEmpty) return;

    setState(() {
      _isAvailabilityLoading = true;
    });

    final useCase = getIt<GetBookingAvailabilityUseCase>();
    final futures = missingBarbers.map((barber) {
      return useCase(
        BookingAvailabilityQuery(
          barberId: barber.id,
          serviceId: serviceId,
          date: dateKey,
        ),
      );
    }).toList();

    final results = await Future.wait(futures);
    if (!mounted) return;

    for (var i = 0; i < results.length; i++) {
      results[i].fold(
        (_) {},
        (availability) {
          _availabilityByBarberIdDate
              .putIfAbsent(missingBarbers[i].id, () => {})
              .addAll({dateKey: availability});
        },
      );
    }

    if (mounted) {
      setState(() {
        _isAvailabilityLoading = false;
      });
    } else {
      _isAvailabilityLoading = false;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _barbersBloc.close();
    _bookingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final backgroundColor = isDark
            ? AppColors.backgroundDark
            : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;
        final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _barbersBloc),
            BlocProvider.value(value: _bookingBloc),
          ],
          child: MultiBlocListener(
            listeners: [
              BlocListener<BarbersByShopServiceBloc, BarbersByShopServiceState>(
                listener: (context, state) {
                  if (state is BarbersByShopServiceLoaded) {
                    final mastersList = state.barbers.map((barber) {
                      final nameParts = barber.fullName.trim().split(RegExp(r'\s+'));
                      final name = nameParts.isNotEmpty ? nameParts.first : '';
                      final surname = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
                      final rating = double.tryParse(barber.avgReyting) ?? 0;
                      final imageUrl = barber.img.isEmpty
                          ? ''
                          : barber.img.startsWith('http')
                              ? barber.img
                              : '${Constants.imageBaseUrl}${barber.img}';
                      return Master(
                        id: barber.id,
                        name: name,
                        surname: surname,
                        rating: rating,
                        reviewCount: barber.ratings.length,
                        imageUrl: imageUrl,
                        yearsExperience: 0,
                        availableTimeSlots: const [],
                        bio: barber.bio,
                      );
                    }).toList();
                    _currentBarbers = mastersList;
                    _loadAvailabilityForBarbers(mastersList, selectedDate);
                  }
                },
              ),
              BlocListener<BookingBloc, BookingState>(
                listener: (context, state) {
                  if (state is BookingSuccess) {
                    if (_isBookingSheetOpen &&
                        Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    setState(() {
                      selectedTimeSlot = null;
                      _availabilityByBarberIdDate.clear();
                      _isAvailabilityLoading = true;
                    });
                    _loadAvailabilityForBarbers(_currentBarbers, selectedDate);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Buyurtma muvaffaqiyatli yaratildi!".tr()),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _bookingBloc.add(const ResetBookingEvent());
                  } else if (state is BookingError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
            child: Scaffold(
              backgroundColor: backgroundColor,
              body: RefreshIndicator(
                color: AppColors.yellow,
                onRefresh: () async {
                  setState(() {
                    _availabilityByBarberIdDate.clear();
                    _isAvailabilityLoading = true;
                    selectedTimeSlot = null;
                  });
                  _loadBarbersOnInit();
                  if (_currentBarbers.isNotEmpty) {
                    await _loadAvailabilityForBarbers(
                      _currentBarbers,
                      selectedDate,
                    );
                  }
                },
                child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                      children: [
                      // Header Image with Back Button
                      Stack(
                        children: [
                          _buildHeaderImage(),
                          SafeArea(
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Shop Info
                      Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.barbershop.name,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          widget.barbershop.rating.toString(),
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Icon(
                                          Icons.star,
                                          color: AppColors.yellow,
                                          size: 18.sp,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isActive(widget.barbershop.status)
                                        ? Colors.green.withValues(alpha: 0.2)
                                        : Colors.red.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(
                                    _isActive(widget.barbershop.status)
                                        ? 'open'.tr()
                                        : 'Yopiq'.tr(),
                                    style: TextStyle(
                                      color: _isActive(widget.barbershop.status)
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  '${widget.barbershop.openTime} - ${widget.barbershop.closeTime}',
                                  style: TextStyle(
                                    color: subtextColor,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: subtextColor,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    '${widget.barbershop.distance.toStringAsFixed(1)} km',
                                    style: TextStyle(
                                      color: subtextColor,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(Icons.phone,
                                    color: subtextColor, size: 16.sp),
                                SizedBox(width: 4.w),
                                Text(
                                  widget.barbershop.phoneNumber.isEmpty
                                      ? '-'
                                      : widget.barbershop.phoneNumber,
                                  style: TextStyle(
                                    color: subtextColor,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    if (widget.barbershop.id.isEmpty) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ConversationPage(
                                          barberId: widget.barbershop.id,
                                          barberName: widget.barbershop.name,
                                          barberImageUrl:
                                              widget.barbershop.imageUrl,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Icon(Icons.message),
                                ),
                              ],
                            ),
                            if (widget.barbershop.description.isNotEmpty) ...[
                              SizedBox(height: 8.h),
                              Text(
                                widget.barbershop.description,
                                style: TextStyle(
                                  color: subtextColor,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        margin: EdgeInsets.symmetric(horizontal: 20.w),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.containerDark
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          indicator: BoxDecoration(
                            color:
                                isDark ? AppColors.backgroundDark : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: AppColors.yellow,
                          unselectedLabelColor: subtextColor,
                          dividerColor: Colors.transparent,
                          labelPadding: EdgeInsets.symmetric(horizontal: 12.w),
                          labelStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          tabs: [
                            Tab(text: 'jadval'.tr()),
                            Tab(text: 'barbers'.tr()),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),
                    ],
                  ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildScheduleTab(isDark, textColor, subtextColor),
                  _buildBarbersTab(isDark, textColor, subtextColor),
                ],
              ),
            ),
            ),
          ),
        ));
      },
    );
  }

  Widget _buildHeaderImage() {
    final imageUrl = widget.barbershop.imageUrl;
    final isAsset = imageUrl.startsWith('assets/');
    final isNetwork = imageUrl.startsWith('http');
    final resolvedUrl =
        isAsset || isNetwork ? imageUrl : '${Constants.imageBaseUrl}$imageUrl';
    final fallback = Container(
      height: 250.h,
      color: Colors.black,
      child: Center(
        child: Icon(Icons.content_cut, color: AppColors.yellow, size: 48.sp),
      ),
    );

    if (imageUrl.isEmpty) {
      return fallback;
    }

    return SizedBox(
      height: 250.h,
      width: double.infinity,
      child: isNetwork || !isAsset
          ? Image.network(
              resolvedUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250.h,
              errorBuilder: (context, error, stackTrace) => fallback,
            )
          : Image.asset(
              resolvedUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250.h,
              errorBuilder: (context, error, stackTrace) => fallback,
            ),
    );
  }

  List<String> _generateAllTimeSlots() {
    final startMinutes = _timeToMinutes('08:00');
    final endMinutes = _timeToMinutes('15:30');

    final slots = <String>[];
    for (var minutes = startMinutes; minutes < endMinutes; minutes += 30) {
      final hour = minutes ~/ 60;
      final minute = minutes % 60;
      slots.add('${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
    }

    return slots;
  }

  BookingAvailability? _availabilityForBarberDate(
    String barberId,
    DateTime date,
  ) {
    final dateKey = _formatAvailabilityDate(date);
    final barberMap = _availabilityByBarberIdDate[barberId];
    return barberMap?[dateKey];
  }

  List<String> _freeSlotsForDate(DateTime date) {
    final Set<String> slots = {};
    final dateKey = _formatAvailabilityDate(date);
    for (final availabilityByDate in _availabilityByBarberIdDate.values) {
      final availability = availabilityByDate[dateKey];
      if (availability == null) continue;
      slots.addAll(
        _filterExpiredSlots(
          date,
          _filterSlotsByBusinessHours(
            _filterToThirtyMinuteSlots(availability.freeSlots),
          ),
        ),
      );
    }
    return slots.toList();
  }

  List<String> _freeSlotsForBarberDate(String barberId, DateTime date) {
    final availability = _availabilityForBarberDate(barberId, date);
    if (availability == null) return const [];
    return _filterExpiredSlots(
      date,
      _filterSlotsByBusinessHours(
        _filterToThirtyMinuteSlots(availability.freeSlots),
      ),
    );
  }

  bool _barberHasAnyAvailability(String barberId) {
    final availabilityByDate = _availabilityByBarberIdDate[barberId];
    if (availabilityByDate == null) return false;
    return availabilityByDate.values
        .any((availability) => availability.freeSlots.isNotEmpty);
  }

  Widget _buildScheduleTab(bool isDark, Color textColor, Color subtextColor) {
    if (_isAvailabilityLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.yellow),
      );
    }
    final freeSlots = _freeSlotsForDate(selectedDate)..sort();
    final availableSlots = freeSlots.map(_toTimeSlot).toList();
    final displaySelectedTime = selectedTimeSlot != null &&
            freeSlots.contains(selectedTimeSlot)
        ? selectedTimeSlot
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 48.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: availableDates.length,
            itemBuilder: (context, index) {
              final date = availableDates[index];
              final now = DateTime.now();
              final isToday =
                  date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;
              final isSelected =
                  selectedDate.day == date.day &&
                  selectedDate.month == date.month;
              return _buildDateCard(
                date,
                isSelected,
                isDark,
                textColor,
                subtextColor,
                isToday: isToday,
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        if (displaySelectedTime != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'Tanlangan vaqt: ${DateFormat('dd MMM').format(selectedDate)} '
              '${displaySelectedTime ?? ''}',
              style: TextStyle(
                color: textColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],

        // Time Slots
        Expanded(
          child: availableSlots.isEmpty
              ? Center(
                  child: Text(
                    "Bo'sh vaqtlar topilmadi",
                    style: TextStyle(color: subtextColor, fontSize: 14.sp),
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: availableSlots.length,
                  itemBuilder: (context, index) {
                    final timeSlot = availableSlots[index];
                    final isSelected =
                        selectedTimeSlot == timeSlot.startTime;
                    return _buildTimeSlotCard(
                      timeSlot,
                      isSelected,
                      isDark,
                      textColor,
                      isAvailable: true,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBarbersTab(bool isDark, Color textColor, Color subtextColor) {
    if (widget.serviceId == null || widget.serviceId!.isEmpty) {
      return Center(
        child: Text(
          'Service not selected',
          style: TextStyle(color: subtextColor, fontSize: 14.sp),
        ),
      );
    }
    final displaySelectedTime =
        selectedTimeSlot != null &&
                _freeSlotsForDate(selectedDate).contains(selectedTimeSlot)
            ? selectedTimeSlot
            : null;
    return BlocBuilder<BarbersByShopServiceBloc, BarbersByShopServiceState>(
      builder: (context, state) {
        if (state is BarbersByShopServiceLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.yellow),
          );
        }
        if (state is BarbersByShopServiceError) {
          return Center(
            child: Text(
              state.message,
              style: TextStyle(color: subtextColor, fontSize: 14.sp),
            ),
          );
        }
        if (state is BarbersByShopServiceLoaded) {
          final mastersList = state.barbers.map((barber) {
            final nameParts = barber.fullName.trim().split(RegExp(r'\s+'));
            final name = nameParts.isNotEmpty ? nameParts.first : '';
            final surname =
                nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
            final rating = double.tryParse(barber.avgReyting) ?? 0;
            final imageUrl = barber.img.isEmpty
                ? ''
                : barber.img.startsWith('http')
                    ? barber.img
                    : '${Constants.imageBaseUrl}${barber.img}';
            return Master(
              id: barber.id,
              name: name,
              surname: surname,
              rating: rating,
              reviewCount: barber.ratings.length,
              imageUrl: imageUrl,
              yearsExperience: 0,
              availableTimeSlots: const [],
              bio: barber.bio,
            );
          }).toList();
          _currentBarbers = mastersList;
          _loadAvailabilityForBarbers(mastersList, selectedDate);
          if (_isAvailabilityLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.yellow),
            );
          }
          if (mastersList.isEmpty) {
            return Center(
              child: Text(
                'sartaroshlar_topilmadi'.tr(),
                style: TextStyle(color: subtextColor, fontSize: 14.sp),
              ),
            );
          }
          return Column(
            children: [
              if (displaySelectedTime != null)
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tanlangan vaqt: ${DateFormat('dd MMM').format(selectedDate)} '
                      '${displaySelectedTime ?? ''}',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  itemCount: mastersList.length,
                  itemBuilder: (context, index) {
                    final master = mastersList[index];
                    return _buildBarberCard(
                      master,
                      isDark,
                      textColor,
                      subtextColor,
                      onTap: () => _showBookingSheet(master, isDark),
                      isEnabled: true,
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDateCard(
    DateTime date,
    bool isSelected,
    bool isDark,
    Color textColor,
    Color subtextColor, {
    required bool isToday,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = date;
          selectedTimeSlot = null;
        });
        _loadAvailabilityForBarbers(_currentBarbers, selectedDate);
      },
      child: Container(
        width: 60.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.yellow
              : isDark
              ? AppColors.containerDark
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark
                      ? Colors.grey.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.3),
                ),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: isToday
                  ? [
                      Text(
                        'bugun'.tr(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : textColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                  : [
                      Text(
                        DateFormat('dd').format(date),
                        style: TextStyle(
                          color: isSelected ? Colors.white : textColor,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(date),
                        style: TextStyle(
                          color: isSelected ? Colors.white : subtextColor,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotCard(
    TimeSlot timeSlot,
    bool isSelected,
    bool isDark,
    Color textColor, {
    bool isAvailable = true,
  }) {
    return GestureDetector(
      onTap: isAvailable
          ? () {
              setState(() {
                selectedTimeSlot = isSelected ? null : timeSlot.startTime;
              });
              if (selectedTimeSlot != null) {
                _tabController.animateTo(1);
              }
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.yellow.withValues(alpha: 0.1)
              : isAvailable
                  ? (isDark
                      ? AppColors.containerDark
                      : Colors.grey.withValues(alpha: 0.1))
                  : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.yellow
                : isAvailable
                    ? isDark
                        ? Colors.grey.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.35),
            width: isSelected ? 2 : (isAvailable ? 1 : 1.5),
          ),
        ),
        child: Center(
          child: Text(
            tr(
              'time_up_to',
              namedArgs: {'start': timeSlot.startTime , 'end': timeSlot.endTime},
            ),
            style: TextStyle(
              color: isSelected
                  ? AppColors.yellow
                  : isAvailable
                      ? textColor
                      : Colors.grey,
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarberCard(
    Master master,
    bool isDark,
    Color textColor,
    Color subtextColor, {
    VoidCallback? onTap,
    bool isEnabled = true,
  }) {
    return Opacity(
      opacity: isEnabled ? 1 : 0.5,
      child: IgnorePointer(
        ignoring: !isEnabled,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.containerDark : Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark
                    ? Colors.grey.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                // Barber Image
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[800],
                    image: master.imageUrl.isEmpty
                        ? null
                        : DecorationImage(
                            image: master.imageUrl.startsWith('http')
                                ? NetworkImage(master.imageUrl)
                                : AssetImage(master.imageUrl) as ImageProvider,
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {},
                          ),
                  ),
                  child: master.imageUrl.isEmpty
                      ? Icon(Icons.person, color: Colors.grey[600], size: 30.sp)
                      : null,
                ),
                SizedBox(width: 12.w),

            // Barber Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${master.name} ${master.surname}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (master.yearsExperience > 0) ...[
                    SizedBox(height: 4.h),
                    Text(
                      tr(
                        'years_experience',
                        namedArgs: {'years': master.yearsExperience.toString()},
                      ),
                      style: TextStyle(color: subtextColor, fontSize: 12.sp),
                    ),
                  ],
                  if (master.bio.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      master.bio,
                      style: TextStyle(color: subtextColor, fontSize: 12.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      ...master.availableTimeSlots.take(3).map((time) {
                        return Container(
                          margin: EdgeInsets.only(right: 4.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.backgroundDark
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(color: textColor, fontSize: 11.sp),
                          ),
                        );
                      }),
                      if (master.availableTimeSlots.length > 3)
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'more'.tr(),
                            style: TextStyle(
                              color: AppColors.yellow,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Rating
            Row(
              children: [
                Text(
                  master.rating.toString(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.star, color: AppColors.yellow, size: 16.sp),
              ],
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isActive(String status) {
    return status.toLowerCase() == 'active';
  }
}

class TimeSlot {
  final String startTime;
  final String endTime;

  TimeSlot({required this.startTime, required this.endTime});
}
