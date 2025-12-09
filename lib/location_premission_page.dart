import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/core/widgets/buttom_navigation_widget.dart';
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
          "Joylashuv o‘chirilgan",
          "Telefoningizda joylashuv xizmati yoqilmagan. Iltimos, sozlamalardan yoqing.",
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
          "Ruxsat berilmadi",
          "Yaqin atrofdagi sartaroshxonalarni ko‘rish uchun joylashuvga ruxsat bering.",
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorDialog(
          "Ruxsat butunlay rad etildi",
          "Ilova ishlay olmaydi. Iltimos, telefon sozlamalaridan BarBros ilovasiga joylashuv ruxsatini bering.",
          onConfirm: () => Geolocator.openAppSettings(),
        );
        return;
      }

      await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => AdvancedCurvedBottomNav(),
          ), // Replace with your main page
        );
      }
    } catch (e) {
      _showErrorDialog("Xatolik", "Joylashuvni aniqlashda xato yuz berdi.");
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
              child: const Text("Sozlamalarga o‘tish"),
            ),
          TextButton(
            onPressed: () => _requestLocationPermission(),
            child: const Text("Qayta urinish"),
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
                    "Joylashuv aniqlanmoqda...",
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
                    "Joylashuvga ruxsat bering",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Yaqin atrofdagi eng yaxshi sartaroshxonalarni topish uchun sizning joylashuvingiz kerak.",
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
                      "Ruxsat berish",
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
