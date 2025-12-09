import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/pages/home_page.dart';
import 'package:bar_bros_user/pages/categories_page.dart';
import 'package:bar_bros_user/pages/chat_page.dart';
import 'package:bar_bros_user/pages/orders_page.dart';
import 'package:bar_bros_user/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdvancedCurvedBottomNav extends StatefulWidget {
  const AdvancedCurvedBottomNav({super.key});

  @override
  State<AdvancedCurvedBottomNav> createState() => _AdvancedCurvedBottomNavState();
}

class _AdvancedCurvedBottomNavState extends State<AdvancedCurvedBottomNav>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<NavBarItem> _items = [
    NavBarItem(iconPath: "assets/svgs/home.svg", label: "Uy"),
    NavBarItem(iconPath: "assets/svgs/categories.svg", label: "Kategoriya"),
    NavBarItem(iconPath: "assets/svgs/orders.svg", label: "Buyurtma"),
    NavBarItem(iconPath: "assets/svgs/chat.svg", label: "Chat"),
    NavBarItem(iconPath: "assets/svgs/profile.svg", label: "Profile"),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() => _selectedIndex = index);
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          BarbershopHomeScreen(),
          CategoriesPage(),
          OrdersPage(),
          ChatPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: CurvedBottomNavigationBar(
        selectedIndex: _selectedIndex,
        items: _items,
        onTap: _onItemTapped,
        animation: _animation,
      ),
    );
  }
}

class NavBarItem {
  final String iconPath;
  final String label;
  NavBarItem({required this.iconPath, required this.label});
}

class CurvedBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final List<NavBarItem> items;
  final Function(int) onTap;
  final Animation<double> animation;

  const CurvedBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onTap,
    required this.animation,
  });

  // Your original method — kept exactly!
  double _getSelectedPosition(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / items.length;
    final centerOffset = (itemWidth - 65) / 2;
    return (selectedIndex * itemWidth) + centerOffset;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 75),
            painter: CurvedNavigationBarPainter(
              selectedIndex: selectedIndex,
              itemCount: items.length,
              animation: animation,
            ),
          ),

          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                left: _getSelectedPosition(context),
                top: -20,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.backgroundDark,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFA500),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          items[selectedIndex].iconPath,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = index == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: isSelected ? 30 : 10),
                        if (!isSelected)
                          SvgPicture.asset(
                            items[index].iconPath,
                            width: 28,
                            height: 28,
                            colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
                          ),
                        if (!isSelected) const SizedBox(height: 4),
                        if (!isSelected)
                          Text(
                            items[index].label,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class CurvedNavigationBarPainter extends CustomPainter {
  final int selectedIndex;
  final int itemCount;
  final Animation<double> animation;

  CurvedNavigationBarPainter({
    required this.selectedIndex,
    required this.itemCount,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final path = Path();
    final itemWidth = size.width / itemCount;
    final curveStartX = selectedIndex * itemWidth;
    final curveEndX = (selectedIndex + 1) * itemWidth;
    final curveCenterX = curveStartX + (itemWidth / 2);

    path.lineTo(curveStartX, 0);

    final curveHeight = 20.0;
    final curveWidth = itemWidth * 0.9;
    final controlPoint1X = curveCenterX - (curveWidth / 3);
    final controlPoint2X = curveCenterX + (curveWidth / 3);

    path.quadraticBezierTo(
      controlPoint1X,
      -curveHeight,
      curveCenterX,
      -curveHeight,
    );

    path.quadraticBezierTo(controlPoint2X, -curveHeight, curveEndX, 0);

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    canvas.drawShadow(path, Colors.black.withOpacity(0.3), 5, true);
  }

  @override
  bool shouldRepaint(CurvedNavigationBarPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.animation != animation;
  }
}