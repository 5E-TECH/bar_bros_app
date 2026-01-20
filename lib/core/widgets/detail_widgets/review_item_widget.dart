import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/features/theme/bloc/theme_bloc.dart';
import 'package:bar_bros_user/models/models_ditails.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class ReviewItemWidget extends StatefulWidget {
  final Review review;

  const ReviewItemWidget({
    Key? key,
    required this.review,
  }) : super(key: key);

  @override
  State<ReviewItemWidget> createState() => _ReviewItemWidgetState();
}

class _ReviewItemWidgetState extends State<ReviewItemWidget> {
  int likeCount = 0;
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        final cardColor = isDark ? AppColors.containerDark : Colors.grey[100]!;
        final textColor = isDark ? Colors.white : Colors.black;
        final subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12.r),
            border: isDark
                ? null
                : Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // User Avatar
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor:
                    isDark ? Colors.grey[800] : Colors.grey[300],
                    child: ClipOval(
                      child: Image.asset(
                        widget.review.imageUrl,
                        fit: BoxFit.cover,
                        width: 48.r,
                        height: 48.r,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            color: AppColors.yellow,
                            size: 24.sp,
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.review.userName,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.review.date,
                          style: TextStyle(
                            color: subtextColor,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Rating Stars
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < widget.review.rating
                            ? Icons.star
                            : Icons.star_border,
                        color: AppColors.yellow,
                        size: 16.sp,
                      );
                    }),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Comment
              Text(
                widget.review.comment,
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 12.h),

              // Action Buttons
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isLiked = !isLiked;
                        likeCount += isLiked ? 1 : -1;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: isLiked ? AppColors.yellow : subtextColor,
                          size: 18.sp,
                        ),
                        if (likeCount > 0) ...[
                          SizedBox(width: 4.w),
                          Text(
                            likeCount.toString(),
                            style: TextStyle(
                              color: subtextColor,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(width: 20.w),

                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('javob_berish_funksiyasi'.tr()),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          color: subtextColor,
                          size: 18.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'javob_berish'.tr(),
                          style: TextStyle(
                            color: subtextColor,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('ulashish_funksiyasi'.tr()),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.share_outlined,
                      color: subtextColor,
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
