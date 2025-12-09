import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ElevatedButtonWidget extends StatelessWidget {
  const ElevatedButtonWidget({
    super.key,
    this.text = "Kirish",
    this.onPressed,
    this.height,
    this.width,
    this.borderRadius,
    this.color,
  });

  final String text;
  final VoidCallback? onPressed;
  final double? height;
  final double? width;
  final double? borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.yellow,

        minimumSize: Size(
          width ?? double.infinity,
          height ?? 60.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style:  TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }
}
