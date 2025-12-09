import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/core/widgets/home_page_widgets/category_tabs.dart';
import 'package:bar_bros_user/core/widgets/home_page_widgets/promo_card.dart';
import 'package:bar_bros_user/core/widgets/home_page_widgets/service_category_widget.dart';
import 'package:bar_bros_user/models/barbershop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

class BarbershopHomeScreen extends StatefulWidget {
  const BarbershopHomeScreen({super.key});

  @override
  State<BarbershopHomeScreen> createState() => _BarbershopHomeScreenState();
}

class _BarbershopHomeScreenState extends State<BarbershopHomeScreen> {
  final PageController _promoPageController = PageController();
  // String _searchQuery = "";
  // String _selectedCategory = "Barchasi";
  int _currentPage = 0;

  final List<int> _filteredBarbershops = [1,2,3,4,5];





  // void _onSearchChanged(String query) {
  //   setState(() {
  //     _searchQuery = query;
  //   });
  // }
  //
  // void _onCategoryChanged(String category) {
  //   setState(() {
  //     _selectedCategory = category;
  //   });
  // }



  @override
  void dispose() {
    _promoPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "BarBros",
          style: TextStyle(fontFamily: "inter", fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: IconButton.outlined(
              onPressed: () {},
              icon: Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: SingleChildScrollView(
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 210.h,
                  child: PageView(
                    controller: _promoPageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      PromoCard(
                        discountTitle: "20% chegirmaga ega bo'ling",
                        subtitle: "Biz bilan birinchi bron qiling",
                      ),
                      PromoCard(
                        discountTitle: "20% chegirmaga ega bo'ling",
                        subtitle: "Biz bilan birinchi bron qiling",
                      ),
                      PromoCard(
                        discountTitle: "20% chegirmaga ega bo'ling",
                        subtitle: "Biz bilan birinchi bron qiling",
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: _currentPage == index ? 12.w : 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.yellow
                            : Colors.grey.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    );
                  }),
                ),
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 16.w),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         "Kategoriya",
                //         style: TextStyle(fontWeight: FontWeight.bold),
                //       ),
                //       TextButton(
                //         onPressed: () {},
                //         child: Text(
                //           "Barchasini ko'rish",
                //           style: TextStyle(color: AppColors.yellow),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // CategoryTabs(
                //   selectedCategory: _selectedCategory,
                //   onCategoryChanged: _onCategoryChanged,
                // ),
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Text(
                    "Erkelar uchun xizmatlar",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _filteredBarbershops.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(32.r),
                        child: Center(
                          child: Text("Hech qanday kategriyalar topilmadi "),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _filteredBarbershops.length,
                        itemBuilder: (context, index) {
                          return ServiceCategory(
                            icon: Iconsax.scissor_1,
                            label: "Soch qirqish",
                            color: Colors.blue,
                          );
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                      ),
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Text(
                    "Ayollar uchun xizmatlar",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _filteredBarbershops.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(32.r),
                        child: Center(
                          child: Text("Hech qanday kategriyalar topilmadi "),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _filteredBarbershops.length,
                        itemBuilder: (context, index) {
                          return ServiceCategory(
                            icon: Iconsax.scissor_1,
                            label: "Soch qirqish",
                            color: Colors.red,
                          );
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
