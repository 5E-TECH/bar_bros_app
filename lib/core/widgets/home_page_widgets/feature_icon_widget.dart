import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bar_bros_user/core/theme/app_colors.dart';

class FeatureIconWidget extends StatelessWidget {
  final IconData icon;
  final String label;

  const FeatureIconWidget({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28.r,
          backgroundColor: AppColors.yellow.withOpacity(0.2),
          child: Icon(icon, color: AppColors.yellow, size: 28.sp),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: 90.w,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
          ),
        ),
      ],
    );
  }
}