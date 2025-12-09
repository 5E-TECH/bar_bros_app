import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // assuming you're using flutter_screenutil

class CommonServicesWidget extends StatelessWidget {
  final String title;

  final String subtitle;

  final IconData icon;

  final Color iconBackgroundColor;

  final Color iconColor;

  final List<Color> gradientColors;

  final Border? iconBorder;

  final VoidCallback? onTap;

  const CommonServicesWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconBackgroundColor = const Color(0xFFF49D3D),
    this.iconColor = Colors.white,
    this.gradientColors = const [AppColors.gradient1, AppColors.gradient2],
    this.iconBorder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: InkWell(
        // if you want ripple effect
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 158.w,
          height: 144.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.only(
            left: 16.w,
            top: 16.h,
            right: 16.w,
            bottom: 12.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: iconBackgroundColor,
                  border:
                      iconBorder ??
                      Border.all(color: Colors.transparent, width: 0),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 28.sp),
              ),

              const Spacer(),

              // Title
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 4.h),

              // Subtitle
              Text(
                subtitle,
                style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
