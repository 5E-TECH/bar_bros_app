import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:bar_bros_user/barbershop_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ServiceCategory extends StatelessWidget {
  final IconData? icon;
  final String? imageUrl;
  final String label;
  final String? categoryId;
  final String? categoryType;

  const ServiceCategory({
    Key? key,
    this.icon,
    this.imageUrl,
    required this.label,
    this.categoryId,
    this.categoryType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 73.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.white,
            elevation: 4,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BarbershopServices(
                      categoryId: categoryId,
                      categoryName: label,
                      categoryType: categoryType,
                    ),
                  ),
                );
              },
              child: SizedBox(
                width: 73.w,
                height: 73.h,
                child: _buildContent(),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Use imageUrl directly if it's already a full URL, otherwise prepend imageBaseUrl
      final fullUrl = imageUrl!.startsWith('http')
          ? imageUrl!
          : '${Constants.imageBaseUrl}$imageUrl';
      final lowerUrl = imageUrl!.toLowerCase();

      // Handle SVG format
      if (lowerUrl.endsWith('.svg')) {
        return Padding(
          padding: EdgeInsets.all(16.r),
          child: SvgPicture.network(
            fullUrl,
            placeholderBuilder: (context) => Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
        );
      }
      // Handle all other image formats (png, jpg, jpeg, gif, webp, bmp, etc.)
      else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            fullUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.category,),
          ),
        );
      }
    }
    return Icon(icon ?? Icons.category,);
  }
}
