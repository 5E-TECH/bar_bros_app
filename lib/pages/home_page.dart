import 'dart:async';

import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/core/widgets/home_page_widgets/promo_card.dart';
import 'package:bar_bros_user/core/widgets/home_page_widgets/service_category_widget.dart';
import 'package:bar_bros_user/core/widgets/text_field_widget.dart';
import 'package:bar_bros_user/features/category/domain/entities/category.dart';
import 'package:bar_bros_user/features/category/presentation/bloc/category_bloc.dart';
import 'package:bar_bros_user/features/service/domain/entities/service.dart';
import 'package:bar_bros_user/features/service/presentation/bloc/service_bloc.dart';
import 'package:bar_bros_user/features/service/presentation/bloc/service_event.dart';
import 'package:bar_bros_user/features/service/presentation/bloc/service_state.dart';
import 'package:bar_bros_user/pages/berbers_page.dart';
import 'package:bar_bros_user/pages/category/man_categories_page.dart';
import 'package:bar_bros_user/pages/category/woman_categories_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class BarbershopHomeScreen extends StatefulWidget {
  const BarbershopHomeScreen({super.key});

  @override
  State<BarbershopHomeScreen> createState() => _BarbershopHomeScreenState();
}

class _BarbershopHomeScreenState extends State<BarbershopHomeScreen> {
  final PageController _promoPageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int _currentPage = 0;
  bool _isSearchActive = false;
  Timer? _autoScrollTimer;
  Timer? _autoScrollRestartTimer;
  CategoryState? _cachedState;
  int _promoPageCount = 0;

  static const Duration _autoScrollDuration = Duration(seconds: 4);
  static const Duration _autoScrollRestartDelay = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    // Trigger category loading immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryBloc>().add(const GetAllCategoriesEvent());
      context.read<ServiceBloc>().add(const GetAllServicesEvent());
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

  Widget _buildLoadingSkeleton() {
    // Get theme brightness to adapt shimmer colors
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      period: const Duration(milliseconds: 400),
      direction: ShimmerDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Promo card skeleton
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
          SizedBox(height: 12.h),
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
                  (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: index == 0 ? 24.w : 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          // Men's section skeleton
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 180.w,
                  height: 22.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                Container(
                  width: 60.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Men's categories grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: List.generate(4, (index) => _buildSkeletonCategoryItem()),
            ),
          ),
          SizedBox(height: 28.h),
          // Women's section skeleton
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 180.w,
                  height: 22.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                Container(
                  width: 60.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Women's categories grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: List.generate(4, (index) => _buildSkeletonCategoryItem()),
            ),
          ),
          SizedBox(height: 20.h),
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
            if (promoServices.length > 1) ...[
              SizedBox(height: 5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(promoServices.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: _currentPage == index ? 12.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.yellow
                          : Colors.grey.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  );
                }),
              ),
            ],
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
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                child: child,
              ),
            );
          },
          child: _isSearchActive
              ? SizedBox(
            key: const ValueKey('search'),
            width: MediaQuery.of(context).size.width * 0.68,
            child: TextFieldWidget(
              hint: "search".tr(),
              prefixIcon: const Icon(Icons.search),
              controller: _searchController,
              focusNode: _searchFocusNode,
              enabled: true,
            ),
          )
              : Text(
            'app_name_styleup'.tr(),
            key: const ValueKey('title'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
        ),
        actions: [
          IconButton.outlined(
              onPressed: () {
                setState(() {
                  _isSearchActive = !_isSearchActive;
                });
                if (_isSearchActive) {
                  _searchFocusNode.requestFocus();
                } else {
                  _searchController.clear();
                  _searchFocusNode.unfocus();
                }
              },
              icon: Icon(_isSearchActive ? Icons.close : Icons.search)),
          IconButton.outlined(
              onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          SizedBox(
            width: 16.w,
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: SingleChildScrollView(
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
                                    child: Text("Qayta urinish".tr()),
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
                          _buildPromoSection(),
                          // Men's categories
                          Padding(
                            padding: EdgeInsets.only(left: 16.w, top: 16.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Erkaklar uchun xizmatlar".tr(),
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
                                    child: Text("SeeAll".tr()))
                              ],
                            ),
                          ),
                          manCategories.isEmpty
                              ? Padding(
                            padding: EdgeInsets.all(32.r),
                            child: Center(
                              child: Text(
                                  "Hech qanday kategoriyalar topilmadi"
                                      .tr()),
                            ),
                          )
                              : Padding(
                            padding:
                            EdgeInsets.symmetric(horizontal: 16.w),
                            child: Wrap(
                              spacing: 12.w,
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
                            padding: EdgeInsets.only(left: 16.w, top: 16.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Ayollar uchun xizmatlar".tr(),
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
                                    child: Text("SeeAll".tr()))
                              ],
                            ),
                          ),
                          womanCategories.isEmpty
                              ? Padding(
                            padding: EdgeInsets.all(32.r),
                            child: Center(
                              child: Text(
                                  "Hech qanday kategoriyalar topilmadi"
                                      .tr()),
                            ),
                          )
                              : Padding(
                            padding:
                            EdgeInsets.symmetric(horizontal: 16.w),
                            child: Wrap(
                              spacing: 12.w,
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
        ),
      ),
    );
  }
}
