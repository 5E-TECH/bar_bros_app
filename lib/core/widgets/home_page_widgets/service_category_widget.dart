import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ServiceCategory extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const ServiceCategory({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 90.w,
          height: 90.h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5.w,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 32,
          ),
        ),
         SizedBox(height: 8.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style:  TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}