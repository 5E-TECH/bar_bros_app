import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTabBar extends StatefulWidget {
  final List<String> tabs;
  final Function(int) onTabChanged;

  const CustomTabBar({Key? key, required this.tabs, required this.onTabChanged})
    : super(key: key);

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.containerDark : AppColors.backgroundLight;
    final selectedBgColor =
        isDark ? AppColors.backgroundDark : AppColors.yellow;
    final selectedTextColor = isDark ? AppColors.yellow : Colors.white;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final tabCount = widget.tabs.length;
    final selectedAlignment = tabCount <= 1
        ? Alignment.center
        : Alignment(
            -1 + (2 * _selectedIndex / (tabCount - 1)),
            0,
          );

    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.center,
            children: [
              AnimatedAlign(
                alignment: selectedAlignment,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: FractionallySizedBox(
                  widthFactor: tabCount == 0 ? 1 : 1 / tabCount,
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: selectedBgColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              Row(
                children: List.generate(
                  tabCount,
                  (index) => Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        widget.onTabChanged(index);
                      },
                      child: Container(
                        height: 48.h,
                        alignment: Alignment.center,
                        child: AnimatedDefaultTextStyle(
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: _selectedIndex == index
                                ? selectedTextColor
                                : Colors.grey,
                          ),
                          duration: const Duration(milliseconds: 250),
                          child: Text(widget.tabs[index]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
