import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final card = isDark ? AppColors.containerDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.primaryDark;
    final subText = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          "contact_title".tr(),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          children: [
            _ContactCard(
              icon: Icons.phone,
              title: "contact_phone_title".tr(),
              value: "contact_phone_value".tr(),
              textColor: textColor,
              subText: subText,
              cardColor: card,
              isDark: isDark,
            ),
            _ContactCard(
              icon: Icons.chat_bubble_outline,
              title: "contact_telegram_title".tr(),
              value: "contact_telegram_value".tr(),
              textColor: textColor,
              subText: subText,
              cardColor: card,
              isDark: isDark,
            ),
            _ContactCard(
              icon: Icons.email_outlined,
              title: "contact_email_title".tr(),
              value: "contact_email_value".tr(),
              textColor: textColor,
              subText: subText,
              cardColor: card,
              isDark: isDark,
            ),
            _ContactCard(
              icon: Icons.location_on_outlined,
              title: "contact_address_title".tr(),
              value: "contact_address_value".tr(),
              textColor: textColor,
              subText: subText,
              cardColor: card,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color textColor;
  final Color subText;
  final Color cardColor;
  final bool isDark;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.textColor,
    required this.subText,
    required this.cardColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.yellow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: AppColors.yellow,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: subText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
