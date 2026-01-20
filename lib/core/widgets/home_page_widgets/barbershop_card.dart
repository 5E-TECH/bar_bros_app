import 'package:bar_bros_user/pages/barbershop_detail.dart';
import 'package:flutter/material.dart';
import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/models/barbershop.dart';
import 'package:bar_bros_user/features/theme/bloc/theme_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BarbershopCard extends StatelessWidget {
  final Barbershop barbershop;
  final VoidCallback onFavoriteToggle;
  final String? serviceId;

  const BarbershopCard({
    Key? key,
    required this.barbershop,
    required this.onFavoriteToggle,
    this.serviceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final textColor = isDark ? Colors.white : Colors.black;
        final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
        final cardColor = isDark ? AppColors.containerDark : Colors.white;
        final borderColor = isDark
            ? Colors.grey.withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.3);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BarbershopDetailPage(
                  barbershop: barbershop,
                  serviceId: serviceId ?? barbershop.serviceId,
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 16.w),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: borderColor),
              boxShadow: isDark
                  ? []
                  : [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      width: 100.w,
                      height: 100.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: _buildImage(),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Barbershop Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                barbershop.name,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Row(
                              children: [

                                Text(
                                  barbershop.rating.toString(),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(Icons.star,
                                    size: 16.sp, color: AppColors.yellow),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${barbershop.distance.toStringAsFixed(1)} km',
                          style: TextStyle(
                            color: subtextColor,
                            fontSize: 14.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey.withValues(alpha:0.2)
                                    : Colors.grey.withValues(alpha:0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14.sp,
                                    color: AppColors.yellow,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    '${barbershop.openTime} - ${barbershop.closeTime}',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey.withValues(alpha: 0.2)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                '${barbershop.price} UZS',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                ),
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
          ),
        );
      },
    );
  }

  Widget _buildImage() {
    final isNetwork = barbershop.imageUrl.startsWith('http');
    final fallback = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.yellow.withValues(alpha: 0.3),
            Colors.grey[800]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.content_cut,
        size: 40.sp,
        color: AppColors.yellow,
      ),
    );

    return isNetwork
        ? Image.network(
            barbershop.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => fallback,
          )
        : Image.asset(
            barbershop.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => fallback,
          );
  }

  bool _isActive(String status) {
    return status.toLowerCase() == 'active';
  }
}
