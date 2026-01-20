import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/core/widgets/logout_button.dart';
import 'package:bar_bros_user/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bar_bros_user/features/theme/bloc/theme_bloc.dart';
import 'package:bar_bros_user/pages/about_app_page.dart';
import 'package:bar_bros_user/pages/contact_page.dart';
import 'package:bar_bros_user/pages/credit_card/cards_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _localName = '';
  String _localPhone = '';
  String _localImagePath = '';
  bool _pageVisible = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const CheckAuthStatusEvent());
    _loadLocalProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _pageVisible = true);
      }
    });
  }

  Future<void> _loadLocalProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _localName = [
        prefs.getString('profile_first_name') ?? '',
        prefs.getString('profile_last_name') ?? '',
      ].where((v) => v.trim().isNotEmpty).join(' ');
      _localPhone = prefs.getString('profile_phone') ?? '';
      _localImagePath = prefs.getString('profile_image_path') ?? '';
    });
  }

  // Share app function
  void _shareApp() {
    final String appName = "StyleUp";

    // Get localized message based on current language
    String message;
    if (context.locale.languageCode == 'uz') {
      message = """
🎨 $appName - Sartaroshxona va Go'zallik Xizmatlari

Eng yaxshi sartaroshxonalar va go'zallik salonlarini toping!

📱 Ilovani yuklab oling:
https://play.google.com/store/apps/details?id=com.barbros.user

✨ Xizmatlar:
• Soch turmaklash
• Soqol olish
• Styling
• Manikür & Pedikür

🎯 Bugun band qiling!
""";
    } else if (context.locale.languageCode == 'ru') {
      message = """
🎨 $appName - Парикмахерская и Салоны Красоты

Найдите лучшие парикмахерские и салоны красоты!

📱 Скачать приложение:
https://play.google.com/store/apps/details?id=com.barbros.user

✨ Услуги:
• Стрижка
• Бритье
• Стайлинг
• Маникюр и Педикюр

🎯 Забронируйте сегодня!
""";
    } else {
      message = """
🎨 $appName - Barbershop & Beauty Services

Find the best barbershops and beauty salons!

📱 Download the app:
https://play.google.com/store/apps/details?id=com.barbros.user

✨ Services:
• Haircut
• Shave
• Styling
• Manicure & Pedicure

🎯 Book today!
""";
    }

    try {
      Share.share(
        message,
        subject: appName,
      );
    } catch (e) {
      // Show error message if sharing fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ulashishda xatolik yuz berdi".tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.primaryLight : AppColors.primaryDark;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "profil".tr(),
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ),
        body: AnimatedOpacity(
          opacity: _pageVisible ? 1 : 0,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
          child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
            child: Column(
              children: [
                // Profile Section with Avatar and Name
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return _buildLoadingProfile(isDark);
                    }

                    String displayName = _localName;
                    String phoneNumber = _localPhone;

                    if (state is AuthAuthenticated &&
                        state.fullName != null &&
                        state.fullName!.trim().isNotEmpty) {
                      displayName = state.fullName!.trim();
                    }
                    if (state is AuthAuthenticated &&
                        state.phoneNumber.isNotEmpty) {
                      phoneNumber = state.phoneNumber;
                    }

                    if (displayName.isEmpty) {
                      return _buildLoadingProfile(isDark);
                    }

                    return _buildProfileHeader(
                      context,
                      displayName,
                      phoneNumber,
                      isDark,
                      imagePath: _localImagePath,
                    );
                  },
                ),

                SizedBox(height: 20.h),

                // // Menu Items
                // _buildMenuItem(
                //   isDark: isDark,
                //   icon: Icons.business,
                //   iconColor: AppColors.yellow,
                //   title: "styleup_app".tr(),
                //   onTap: () {
                //     // Navigate to business app
                //   },
                // ),

                _buildMenuItem(
                  isDark: isDark,
                  icon: Icons.phone,
                  iconColor: AppColors.yellow,
                  title: "aloqa".tr(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactPage(),
                      ),
                    );
                  },
                ),

                // Theme Toggle
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return _buildElevatedCard(
                      isDark: isDark,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.yellow.withValues(
                            alpha: 0.15,
                          ),
                          child: Icon(
                            state.isDark ? Icons.dark_mode : Icons.light_mode,
                            color: AppColors.yellow,
                          ),
                        ),
                        title: Text(
                          state.isDark
                              ? "tungi_rejim".tr()
                              : "kundizgi_rejim".tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                        trailing: Switch(
                          value: state.isDark,
                          activeThumbColor: AppColors.yellow,
                          activeTrackColor: AppColors.yellow.withValues(
                            alpha: 0.4,
                          ),
                          onChanged: (_) =>
                              context.read<ThemeBloc>().add(ToggleTheme()),
                        ),
                      ),
                    );
                  },
                ),

                _buildMenuItem(
                  isDark: isDark,
                  icon: Icons.language,
                  iconColor: AppColors.yellow,
                  title: "til".tr(),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20.r)),
                      ),
                      builder: (context) {
                        return SafeArea(
                          top: false,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    height: 5.h,
                                    width: 40.w,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  "choose_language".tr(),
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                _buildLanguageOption(
                                  context: context,
                                  isDark: isDark,
                                  label: "O'zbekcha",
                                  locale: const Locale('uz'),
                                ),
                                Divider(height: 1.h),
                                _buildLanguageOption(
                                  context: context,
                                  isDark: isDark,
                                  label: "Русский",
                                  locale: const Locale('ru'),
                                ),
                                Divider(height: 1.h),
                                _buildLanguageOption(
                                  context: context,
                                  isDark: isDark,
                                  label: "English",
                                  locale: const Locale('en'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return _buildElevatedCard(
                      isDark: isDark,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.yellow.withValues(
                            alpha: 0.15,
                          ),
                          child: const Icon(
                            Icons.credit_card,
                            color: AppColors.yellow,
                          ),
                        ),
                        title: Text(
                          "cards_menu".tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CardsPage(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                // Share App Menu Item with share function
                _buildMenuItem(
                  isDark: isDark,
                  icon: Icons.share,
                  iconColor: AppColors.yellow,
                  title: "ilovani_ulashish".tr(),
                  onTap: _shareApp, // Call the share function here
                ),

                _buildMenuItem(
                  isDark: isDark,
                  icon: Icons.info,
                  iconColor: AppColors.yellow,
                  title: "about_app_title".tr(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutAppPage(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 35.h,),

                // Logout Button
                const LogoutButtonWidget(text: "akkountdan_chiqish"),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingProfile(bool isDark) {
    return _buildElevatedCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor: AppColors.yellow.withValues(alpha: 0.2),
              child: const CircularProgressIndicator(
                color: AppColors.yellow,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: isDark ? 0.25 : 0.3),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: 120.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: isDark ? 0.2 : 0.3),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context,
      String displayName,
      String phoneNumber,
      bool isDark, {
      String? imagePath,
      }) {
    final file = imagePath == null ? null : File(imagePath);
    final hasImage =
        file != null && imagePath!.isNotEmpty && file.existsSync();
    return _buildElevatedCard(
      isDark: isDark,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        leading: CircleAvatar(
          radius: 30.r,
          backgroundColor: AppColors.yellow.withValues(alpha: 0.2),
          backgroundImage: hasImage ? FileImage(file) : null,
          child: hasImage
              ? null
              : Text(
                  displayName[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 28.sp,
                    color: AppColors.yellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Text(
          displayName,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
          ),
        ),
        subtitle: Text(
          phoneNumber.isNotEmpty ? phoneNumber : "—",
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? Colors.white70 : Colors.grey[700],
        ),
        onTap: () {
          // Navigate to Edit Profile Page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePage(
                currentName: displayName,
                currentPhoneNumber: phoneNumber,
              ),
            ),
          ).then((_) => _loadLocalProfile());
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return _buildElevatedCard(
      isDark: isDark,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.15),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? Colors.white70 : Colors.grey[700],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required bool isDark,
    required String label,
    required Locale locale,
  }) {
    final isSelected = context.locale == locale;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: AppColors.yellow,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
        ),
      ),
      onTap: () {
        context.setLocale(locale);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildElevatedCard({
    required bool isDark,
    required Widget child,
  }) {
    final cardColor =
        isDark ? AppColors.containerDark : AppColors.containerLight;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
  }
}
