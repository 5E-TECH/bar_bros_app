import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/pages/home_page.dart';
import 'package:bar_bros_user/pages/profile/profile_page_updated.dart';
import 'package:bar_bros_user/pages/tarix/history_page.dart';
import 'package:bar_bros_user/pages/chat/chat_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdvancedCurvedBottomNav extends StatefulWidget {
  const AdvancedCurvedBottomNav({super.key});

  @override
  State<AdvancedCurvedBottomNav> createState() => _AdvancedCurvedBottomNavState();
}

class _AdvancedCurvedBottomNavState extends State<AdvancedCurvedBottomNav> {
  static int _lastIndex = 0;
  int _selectedIndex = 0;
  late final PageController _pageController;

  List<NavBarItem> get _items => [
    NavBarItem(iconPath: "assets/svgs/home.svg", label: "uy".tr()),
    NavBarItem(iconPath: "assets/svgs/orders.svg", label: "buyurtma".tr()),
    NavBarItem(iconPath: "assets/svgs/chat.svg", label: "chat".tr()),
    NavBarItem(iconPath: "assets/svgs/profile.svg", label: "profile".tr()),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _lastIndex = index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = _lastIndex;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navColor = isDark ? AppColors.containerDark : AppColors.backgroundLight;
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
          _lastIndex = index;
        },
        children: const [
          BarbershopHomeScreen(),
          HistoryPage(),
          ChatPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          hoverColor: Colors.transparent,
        ),
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: navColor,
              selectedItemColor: AppColors.yellow,
              unselectedItemColor: Theme.of(context)
                  .bottomNavigationBarTheme
                  .unselectedItemColor,
              selectedFontSize: 12,
              unselectedFontSize: 10,
              elevation: 0,
              enableFeedback: false,
              items: _items.map((item) {
                return BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    item.iconPath,
                    width: 28,
                    height: 28,
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
                    width: 28,
                    height: 28,
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
