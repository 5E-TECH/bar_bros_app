import 'dart:async';

import 'package:bar_bros_user/signin_page.dart';
import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/core/widgets/elevated_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/widgets/home_page_widgets/feature_icon_widget.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final List<String> _images = [
    "assets/images/onboarding 1.png",
    "assets/images/onboarding 2.png",
  ];

  final List<Map<String, String>> _contents = [
    {
      "title": "BarBrosga Xush Kelibsiz !",
      "subtitle":
          "Eng yaxshi stilistlar va sartaroshlar bilan\nuchrashuvlarni bron qiling. Hamma\nuchun, istalgan vaqtda professional\nsartaroshlar.",
    },
    {
      "title": "",
      "subtitle":
          "Zamonaviy erkaklar va ayollar uchun\nmo'ljallangan sartaroshlik\nxizmatlaridan foydalaning",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      int nextPage = (_currentPage + 1) % 2;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: 2,
            itemBuilder: (context, index) {
              return Image.asset(_images[index], fit: BoxFit.cover);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54, Colors.black87],
                  stops: [0.3, 0.5, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Spacer(),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    child: Column(
                      key: ValueKey(_currentPage),
                      children: [
                        Text(
                          _contents[_currentPage]["title"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          _contents[_currentPage]["subtitle"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),

                  if (_currentPage == 1)
                    Column(
                      children: [
                        Row(
                          spacing: 5,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FeatureIconWidget(
                              icon: Icons.star,
                              label: "Tajribali stilistlar",
                            ),
                            FeatureIconWidget(
                              icon: Icons.access_time,
                              label: "Oson bron qilish",
                            ),
                            FeatureIconWidget(
                              icon: Icons.card_giftcard,
                              label: "Premium mahsulotlar",
                            ),
                          ],
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(2, (index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: _currentPage == index ? 12.w : 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.yellow
                              : Colors.white.withValues(alpha: 0.5),

                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 40.h),
                  ElevatedButtonWidget(
                    text: "Boshlash",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
