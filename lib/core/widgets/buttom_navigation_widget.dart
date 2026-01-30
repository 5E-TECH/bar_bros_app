import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/pages/home_page.dart';
import 'package:bar_bros_user/pages/search.dart';
import 'package:bar_bros_user/pages/tarix/history_page.dart';
import 'package:bar_bros_user/pages/chat/chat_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdvancedCurvedBottomNav extends StatefulWidget {
  const AdvancedCurvedBottomNav({super.key});

  @override
  State<AdvancedCurvedBottomNav> createState() => _AdvancedCurvedBottomNavState();
}

class _AdvancedCurvedBottomNavState extends State<AdvancedCurvedBottomNav> {
  static int _lastIndex = 0;
  int _selectedIndex = 0;

  List<NavBarItem> get _items => [
    NavBarItem(iconPath: "assets/svgs/home.svg", label: "uy".tr()),
    NavBarItem(iconPath: "assets/svgs/search.svg", label: "search".tr()),
    NavBarItem(iconPath: "assets/svgs/orders.svg", label: "buyurtma".tr()),
    NavBarItem(iconPath: "assets/svgs/chat.svg", label: "chat".tr()),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _lastIndex = index;
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = _lastIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navColor = isDark ? Colors.grey[900]! : Colors.grey[100]!;
    return Scaffold(
      extendBody: false,
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          BarbershopHomeScreen(),
          SearchPage(),
          HistoryPage(),
          ChatPage(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          hoverColor: Colors.transparent,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: navColor,
              selectedItemColor: AppColors.yellow,
              unselectedItemColor: Theme.of(context)
                  .bottomNavigationBarTheme
                  .unselectedItemColor,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              elevation: 0,
              enableFeedback: false,
              items: _items.map((item) {
                return BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    item.iconPath,
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context)
                          .bottomNavigationBarTheme
                          .unselectedItemColor ??
                          Colors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                  activeIcon: SvgPicture.asset(
                    item.iconPath,
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(
                      AppColors.yellow,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: item.label,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class NavBarItem {
  final String iconPath;
  final String label;
  NavBarItem({required this.iconPath, required this.label});
}