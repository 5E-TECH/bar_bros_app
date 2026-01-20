import 'package:bar_bros_user/core/di/ingector.dart';
import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/core/widgets/home_page_widgets/barbershop_card.dart';
import 'package:bar_bros_user/core/widgets/text_field_widget.dart';
import 'package:bar_bros_user/features/barber_shop/domain/entities/barber_shop_item.dart';
import 'package:bar_bros_user/features/barber_shop_services/domain/entities/barber_shop_service.dart';
import 'package:bar_bros_user/features/barber_shop_services/domain/entities/barber_shop_service_query.dart';
import 'package:bar_bros_user/features/barber_shop_services/presentation/bloc/barber_shop_service_bloc.dart';
import 'package:bar_bros_user/features/barber_shop_services/presentation/bloc/barber_shop_service_event.dart';
import 'package:bar_bros_user/features/barber_shop_services/presentation/bloc/barber_shop_service_state.dart';
import 'package:bar_bros_user/features/barber_shop/domain/entities/barber_shop_item.dart';
import 'package:bar_bros_user/features/barber_shop/domain/entities/barber_shop_query.dart';
import 'package:bar_bros_user/features/barber_shop/domain/usecases/get_barber_shops_usecase.dart';
import 'package:bar_bros_user/features/service/domain/usecases/get_all_services_usecase.dart';
import 'package:bar_bros_user/features/theme/bloc/theme_bloc.dart';
import 'package:bar_bros_user/models/barbershop.dart';
import 'package:bar_bros_user/core/usecase/usecase.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BarbersPage extends StatefulWidget {
  final String? serviceId;

  const BarbersPage({super.key, this.serviceId});

  @override
  State<BarbersPage> createState() => _BarbersPageState();
}

class _BarbersPageState extends State<BarbersPage> {
  final TextEditingController _searchController = TextEditingController();
  final BarberShopServiceBloc _serviceBloc = getIt<BarberShopServiceBloc>();
  String _searchQuery = "";
  int? _selectedRating;
  String? _serviceImageUrl;
  bool _isServiceImageLoading = false;
  double? _lat;
  double? _lng;
  final Map<String, BarberShopItem> _shopIndex = {};
  static const double _defaultRadiusKm = 10;
  static const double _defaultDistance = 0;

  final List<Barbershop> _allBarbershops = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _loadLocationAndServices();
    _loadServiceImage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _serviceBloc.close();
    super.dispose();
  }

  void _toggleFavorite(Barbershop shop) {
    final index = _allBarbershops.indexOf(shop);
    if (index != -1) {
      setState(() {
        _allBarbershops[index].isFavorite =
        !_allBarbershops[index].isFavorite;
      });
    }
  }

  Future<void> _loadLocationAndServices() async {
    final serviceId = widget.serviceId ?? '';
    if (serviceId.isEmpty) {
      return;
    }
    final useCase = getIt<GetBarberShopsUseCase>();
    final result = await useCase(const BarberShopQuery(limit: 100, page: 1));
    result.fold(
      (_) {
        _lat = 0;
        _lng = 0;
      },
      (shops) {
        _shopIndex
          ..clear()
          ..addEntries(shops.map((item) => MapEntry(item.id, item)));
        BarberShopItem? shop;
        for (final item in shops) {
          if (!item.isDeleted) {
            shop = item;
            break;
          }
        }
        shop ??= shops.isNotEmpty ? shops.first : null;
        _lat = shop?.latitude ?? 0;
        _lng = shop?.longitude ?? 0;
      },
    );
    if (!mounted) return;
    _requestServices();
  }

  Future<void> _loadServiceImage() async {
    final serviceId = widget.serviceId ?? '';
    if (serviceId.isEmpty) {
      return;
    }
    setState(() {
      _isServiceImageLoading = true;
    });
    final useCase = getIt<GetAllServicesUseCase>();
    final result = await useCase(NoParams());
    result.fold(
      (_) => null,
      (services) {
        for (final service in services) {
          if (service.id == serviceId && !service.isDeleted) {
            final image = service.serviceImages.isNotEmpty
                ? service.serviceImages.first
                : service.image;
            if (image.isNotEmpty) {
              _serviceImageUrl = image.startsWith('http')
                  ? image
                  : '${Constants.imageBaseUrl}$image';
            }
            break;
          }
        }
      },
    );
    if (!mounted) return;
    setState(() {
      _isServiceImageLoading = false;
    });
  }

  void _requestServices() {
    final serviceId = widget.serviceId ?? '';
    if (serviceId.isEmpty) {
      return;
    }
    _serviceBloc.add(
      GetAllBarberShopServicesEvent(
        query: BarberShopServiceQuery(
          serviceId: serviceId,
          distance: _defaultDistance,
          avgRating: _selectedRating ?? 0,
          radiusKm: _defaultRadiusKm,
          lat: _lat ?? 0,
          lng: _lng ?? 0,
        ),
      ),
    );
  }

  List<Barbershop> get _filtered {
    if (_searchQuery.isEmpty && _selectedRating == null) {
      return _allBarbershops;
    }

    return _allBarbershops.where((shop) {
      final query = _searchQuery.toLowerCase();
      final matchesQuery = query.isEmpty ||
          shop.name.toLowerCase().contains(query) ||
          shop.location.toLowerCase().contains(query);
      final matchesRating =
          _selectedRating == null || shop.rating >= _selectedRating!;
      return matchesQuery && matchesRating;
    }).toList();
  }

  List<Barbershop> _fromServices(
    List<BarberShopService> items,
  ) {
    return items.map((item) {
      final shop = _shopIndex[item.barberShopId];
      return Barbershop(
        id: item.barberShopId,
        serviceId: widget.serviceId,
        name: item.shopName,
        location: item.shopLocation,
        distance: item.distanceKm,
        rating: double.tryParse(item.avgRating) ?? 0,
        imageUrl: item.shopImage.startsWith('http')
            ? item.shopImage
            : item.shopImage.isEmpty
                ? 'assets/images/barber.png'
                : '${Constants.imageBaseUrl}${item.shopImage}',
        openTime: '08:00',
        closeTime: '15:30',
        description: shop?.description ?? '',
        phoneNumber: shop?.phoneNumber ?? '',
        status: shop?.status ?? 'active',
        price: item.price,
        isFavorite: false,
      );
    }).toList();
  }

  void _openFilterSheet(ThemeState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          state.isDark ? AppColors.backgroundDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        int? tempRating = _selectedRating;
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    Text(
                      "ratingni_tanlang".tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: state.isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 5.w,
                      children: List.generate(5, (index) {
                        final rating = index + 1;
                        final isSelected = tempRating == rating;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              tempRating = isSelected ? null : rating;
                            });
                            setState(() {
                              _selectedRating = isSelected ? null : rating;
                            });
                            _requestServices();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.yellow.withValues(alpha: 0.15)
                                  : (state.isDark
                                      ? AppColors.containerDark
                                      : Colors.grey.withValues(alpha: 0.1)),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.yellow
                                    : Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              spacing: 5,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14.sp,
                                  color: isSelected
                                      ? AppColors.yellow
                                      : Colors.grey,
                                ),
                                Text(
                                  rating.toString(),
                                  style: TextStyle(
                                    color: state.isDark
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildServiceImage() {
    if (_isServiceImageLoading) {
      return SizedBox(
        height: 120.h,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.yellow),
        ),
      );
    }
    final imageUrl = _serviceImageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    final isSvg = imageUrl.toLowerCase().endsWith('.svg');
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: AspectRatio(
        aspectRatio: 16 / 7,
        child: isSvg
            ? SvgPicture.network(
                imageUrl,
                fit: BoxFit.cover,
                placeholderBuilder: (_) => Center(
                  child: CircularProgressIndicator(color: AppColors.yellow),
                ),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.yellow,
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey.withValues(alpha: 0.2)),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceId = widget.serviceId ?? '';
    return BlocProvider.value(
      value: _serviceBloc,
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: true,
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Column(
                children: [
                  _buildServiceImage(),
                  if (_serviceImageUrl != null) SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextFieldWidget(
                          filled: true,
                          fillColor: state.isDark
                              ? AppColors.backgroundDark
                              : AppColors.primaryLight,
                          controller: _searchController,
                          prefixIcon: Icon(Icons.search),
                          hint: "sartaroshlarni_qidirish".tr(),
                          enabled: true,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        onPressed: () => _openFilterSheet(state),
                        icon: SvgPicture.asset(
                          "assets/svgs/filter.svg",
                          width: 22.w,
                          height: 22.w,
                          colorFilter: ColorFilter.mode(
                            state.isDark ? Colors.white : Colors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Expanded(
                    child: BlocBuilder<BarberShopServiceBloc,
                        BarberShopServiceState>(
                      builder: (context, servicesState) {
                        if (servicesState is BarberShopServiceInitial ||
                            servicesState is BarberShopServiceLoading) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.yellow,
                            ),
                          );
                        }
                        if (servicesState is BarberShopServiceError) {
                          return Center(
                            child: Text(
                              servicesState.message,
                              style: TextStyle(fontSize: 18.sp),
                            ),
                          );
                        }
                        final items = servicesState is BarberShopServiceLoaded
                            ? servicesState.services
                            : <BarberShopService>[];
                        if (serviceId.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        if (items.isEmpty) {
                          return Center(
                            child: Text(
                              "sartaroshlar_topilmadi".tr(),
                              style: TextStyle(fontSize: 18.sp),
                            ),
                          );
                        }
                        final shops = _fromServices(items);
                        final results =
                            _searchQuery.isEmpty && _selectedRating == null
                                ? shops
                                : shops.where((shop) {
                                    final query = _searchQuery.toLowerCase();
                                    final matchesQuery = query.isEmpty ||
                                        shop.name
                                            .toLowerCase()
                                            .contains(query) ||
                                        shop.location
                                            .toLowerCase()
                                            .contains(query);
                                    final matchesRating =
                                        _selectedRating == null ||
                                            shop.rating >= _selectedRating!;
                                    return matchesQuery && matchesRating;
                                  }).toList();
                        return results.isEmpty
                            ? Center(
                                child: Text(
                                  "sartaroshlar_topilmadi".tr(),
                                  style: TextStyle(fontSize: 18.sp),
                                ),
                              )
                            : ListView.builder(
                                itemCount: results.length,
                                itemBuilder: (context, index) {
                                  final barber = results[index];
                                  return BarbershopCard(
                                    barbershop: barber,
                                    onFavoriteToggle: () =>
                                        _toggleFavorite(barber),
                                    serviceId: serviceId,
                                  );
                                },
                              );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
