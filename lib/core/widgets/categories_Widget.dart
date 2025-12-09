import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CategoriesWidget extends StatelessWidget {
  final String title;
  final String count;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final double borderRadius;

  const CategoriesWidget({
    super.key,
    this.title = "Category",
    this.count = "0",
    this.width = 180,
    this.height = 103,
    this.padding = const EdgeInsets.only(left: 10),
    this.backgroundColor = AppColors.yellow,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          Text(
            count,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
