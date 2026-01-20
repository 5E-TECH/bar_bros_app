import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/core/widgets/buttom_navigation_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionPage extends StatefulWidget {
  const LocationPermissionPage({super.key});

  @override
  State<LocationPermissionPage> createState() => _LocationPermissionPageState();
}

class _LocationPermissionPageState extends State<LocationPermissionPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
  }

  Future<void> _requestLocationPermission() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // 1. Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorDialog(
          "joylashuv_ochirilgan_2".tr(),
          "telefoningizda_joylashuv_xizmati_yoqilmagan_iltimos_sozlamalardan_yoqing"
              .tr(),
          onConfirm: () => Geolocator.openLocationSettings(),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _showErrorDialog(
          "ruxsat_berilmadi".tr(),
          "yaqin_atrofdagi_sartaroshxonalarni_korish_uchun_joylashuvga_ruxsat_bering"
              .tr(),
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorDialog(
          "ruxsat_butunlay_rad_etildi".tr(),
          "ilova_ishlay_olmaydi_iltimos_telefon_sozlamalaridan_barbros_ilovasiga_joylashuv_ruxsatini_bering"
              .tr(),
          onConfirm: () => Geolocator.openAppSettings(),
        );
        return;
      }

      await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => AdvancedCurvedBottomNav(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      _showErrorDialog(
        "xatolik".tr(),
        "joylashuvni_aniqlashda_xato_yuz_berdi".tr(),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(
    String title,
    String message, {
    VoidCallback? onConfirm,
  }) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          if (onConfirm != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: Text("sozlamalarga_otish_2".tr()),
            ),
          TextButton(
            onPressed: () => _requestLocationPermission(),
            child: Text("qayta_urinish".tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   CircularProgressIndicator(color: AppColors.yellow),
                   SizedBox(height: 20.h),
                  Text(
                    "joylashuv_aniqlanmoqda".tr(),
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 100, color: AppColors.yellow),
                  const SizedBox(height: 30),
                  Text(
                    "joylashuvga_ruxsat_bering".tr(),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "yaqin_atrofdagi_eng_yaxshi_sartaroshxonalarni_topish_uchun_sizning_joylashuvingiz_kerak"
                          .tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _requestLocationPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      padding:  EdgeInsets.symmetric(
                        horizontal: 40.w,
                        vertical: 16.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "ruxsat_berish".tr(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
