import 'package:bar_bros_user/pages/barbershop_detail.dart';
import 'package:flutter/material.dart';
import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/models/barbershop.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BarbershopCard extends StatelessWidget {
  final Barbershop barbershop;
  final VoidCallback onFavoriteToggle;

  const BarbershopCard({
    Key? key,
    required this.barbershop,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BarbershopDetailPage(barbershop: barbershop),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: BoxBorder.all(color: Colors.grey.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            children: [
              // Barbershop Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Image.asset(
                    barbershop.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
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
                          size: 40,
                          color: AppColors.yellow,
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // Barbershop Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      barbershop.name,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      barbershop.location,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.yellow,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${barbershop.distance} km',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        SizedBox(width: 16.w),
                        Icon(Icons.star, size: 16, color: AppColors.yellow),
                        SizedBox(width: 4.w),
                        Text(
                          barbershop.rating.toString(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Favorite Button
              IconButton(
                icon: Icon(
                  barbershop.isFavorite
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: barbershop.isFavorite
                      ? AppColors.yellow
                      : Colors.grey[600],
                  size: 28,
                ),
                onPressed: onFavoriteToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
