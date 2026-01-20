import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/features/theme/bloc/theme_bloc.dart';
import 'package:bar_bros_user/models/models_ditails.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MasterItemWidget extends StatelessWidget {
  final Master master;

  const MasterItemWidget({
    Key? key,
    required this.master,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final cardColor = isDark ? AppColors.containerDark : Colors.grey[100]!;
        final textColor = isDark ? Colors.white : Colors.black;
        final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12.r),
            border: isDark
                ? null
                : Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Row(
            children: [
              // Master Image
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.asset(
                    master.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.yellow.withValues(alpha: 0.3),
                              isDark ? Colors.grey[800]! : Colors.grey[300]!,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          color: AppColors.yellow,
                          size: 40.sp,
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(width: 16.w),

              // Master Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      master.name,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      master.surname,
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: AppColors.yellow,
                          size: 10.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${master.rating}',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          tr(
                            'reviews_count',
                            namedArgs: {
                              'count': master.reviewCount.toString(),
                            },
                          ),
                          style: TextStyle(
                            color: subtextColor,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Select Button
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        tr(
                          'master_selected',
                          namedArgs: {
                            'name': master.name,
                            'surname': master.surname,
                          },
                        ),
                      ),
                      backgroundColor: AppColors.yellow,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'tanlash'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
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
}
