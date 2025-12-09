import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/core/widgets/detail_widgets/master_item_widget.dart';
import 'package:bar_bros_user/core/widgets/detail_widgets/review_item_widget.dart';
import 'package:bar_bros_user/core/widgets/detail_widgets/service_item_widget.dart';
import 'package:bar_bros_user/features/theme/bloc/theme_bloc.dart';
import 'package:bar_bros_user/models/barbershop.dart';
import 'package:bar_bros_user/models/models_ditails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BarbershopDetailPage extends StatefulWidget {
  final Barbershop barbershop;

  const BarbershopDetailPage({
    Key? key,
    required this.barbershop,
  }) : super(key: key);

  @override
  State<BarbershopDetailPage> createState() => _BarbershopDetailPageState();
}

class _BarbershopDetailPageState extends State<BarbershopDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isFavorite = false;

  final List<Service> services = [
    Service(
      name: 'Soch kesish',
      price: 50000,
      duration: '30 min',
      icon: Icons.content_cut,
      color: Colors.purple,
    ),
    Service(
      name: 'Soqol olish',
      price: 30000,
      duration: '20 min',
      icon: Icons.face,
      color: Colors.blue,
    ),
    Service(
      name: 'Yuz massaji',
      price: 40000,
      duration: '25 min',
      icon: Icons.spa,
      color: Colors.pink,
    ),
  ];

  final List<Master> masters = [
    Master(
      name: 'Yaxshimuratov',
      surname: 'Yaxshimurod',
      rating: 4.8,
      reviewCount: 120,
      imageUrl: 'assets/images/master1.jpg',
    ),
    Master(
      name: 'Abdullayev',
      surname: 'Jasur',
      rating: 4.9,
      reviewCount: 95,
      imageUrl: 'assets/images/master2.jpg',
    ),
  ];

  final List<Review> reviews = [
    Review(
      userName: 'Yaxshimuratov Yaxshimurod',
      rating: 5.0,
      comment: 'Juda yaxshi xizmat ko\'rsatildi',
      date: '2 kun oldin',
      imageUrl: 'assets/images/user1.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    isFavorite = widget.barbershop.isFavorite;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final backgroundColor = isDark ? AppColors.backgroundDark : Colors.white;
        final cardColor = isDark ? const Color(0xFF2a2a2a) : Colors.grey[100]!;
        final textColor = isDark ? Colors.white : Colors.black;
        final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

        return Scaffold(
          body: Stack(
            children: [
              _buildBackgroundImage(isDark),

              DraggableScrollableSheet(
                initialChildSize: 0.65,
                minChildSize: 0.65,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.r),
                        topRight: Radius.circular(30.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Drag Handle
                        Container(
                          margin: EdgeInsets.only(top: 12.h),
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),

                        // Shop Info
                        Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            children: [
                              Text(
                                widget.barbershop.name,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                widget.barbershop.location,
                                style: TextStyle(
                                  color: subtextColor,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_on,
                                      color: AppColors.yellow, size: 18.sp),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${widget.barbershop.distance} km',
                                    style: TextStyle(
                                        color: subtextColor, fontSize: 14.sp),
                                  ),
                                  SizedBox(width: 20.w),
                                  Icon(Icons.star,
                                      color: AppColors.yellow, size: 18.sp),
                                  SizedBox(width: 4.w),
                                  Text(
                                    widget.barbershop.rating.toString(),
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: isDark
                                      ? null
                                      : Border.all(
                                      color: Colors.grey[300]!, width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.access_time,
                                        color: AppColors.yellow, size: 18.sp),
                                    SizedBox(width: 8.w),
                                    Text(
                                      '10:00 - 17:30',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Tab Bar
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          indicatorColor: AppColors.yellow,
                          indicatorWeight: 3,
                          labelColor: AppColors.yellow,
                          unselectedLabelColor: subtextColor,
                          labelStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          tabs: const [
                            Tab(text: 'Biz haqimizda'),
                            Tab(text: 'Sartaroshlar'),
                            Tab(text: 'Xizmatlar'),
                            Tab(text: 'Rasmlar'),
                            Tab(text: 'Fikrlar'),
                          ],
                        ),

                        // Tab Content
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildAboutTab(scrollController, isDark,
                                  textColor, subtextColor, cardColor),
                              _buildMastersTab(scrollController),
                              _buildServicesTab(scrollController),
                              _buildPhotosTab(scrollController, cardColor),
                              _buildReviewsTab(scrollController),
                            ],
                          ),
                        ),

                        // Book Button
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigate to booking
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.yellow,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                'Bron qilish',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Top Buttons
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color:
                              isFavorite ? AppColors.yellow : Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                isFavorite = !isFavorite;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundImage(bool isDark) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(widget.barbershop.imageUrl),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {},
        ),
      ),
    );
  }

  Widget _buildAboutTab(ScrollController scrollController, bool isDark,
      Color textColor, Color subtextColor, Color cardColor) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ish vaqti',
              style: TextStyle(
                  color: textColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          _buildWorkingHours('Dushanba - Juma', '09:00 - 18:00', subtextColor,
              textColor),
          _buildWorkingHours('Shanba', '10:00 - 17:00', subtextColor, textColor),
          _buildWorkingHours('Yakshanba', 'Yopiq', subtextColor, textColor),
          SizedBox(height: 24.h),
          Text('Telefon raqam',
              style: TextStyle(
                  color: textColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12.r),
              border: isDark
                  ? null
                  : Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('+998 (88) 888 71 00',
                    style: TextStyle(
                        color: AppColors.yellow,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500)),
                Icon(Icons.phone, color: AppColors.yellow),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHours(
      String day, String hours, Color subtextColor, Color textColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: TextStyle(color: subtextColor, fontSize: 14.sp)),
          Text(hours,
              style: TextStyle(
                  color: textColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMastersTab(ScrollController scrollController) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(16.w),
      itemCount: masters.length,
      itemBuilder: (context, index) => MasterItemWidget(master: masters[index]),
    );
  }

  Widget _buildServicesTab(ScrollController scrollController) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(16.w),
      itemCount: services.length,
      itemBuilder: (context, index) =>
          ServiceItemWidget(service: services[index]),
    );
  }

  Widget _buildPhotosTab(ScrollController scrollController, Color cardColor) {
    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(Icons.image, color: Colors.grey[600], size: 48.sp),
      ),
    );
  }

  Widget _buildReviewsTab(ScrollController scrollController) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(16.w),
      itemCount: reviews.length,
      itemBuilder: (context, index) => ReviewItemWidget(review: reviews[index]),
    );
  }
}