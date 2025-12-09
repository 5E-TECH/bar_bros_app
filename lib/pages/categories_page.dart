import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/core/widgets/common_services_widget.dart';
import 'package:bar_bros_user/core/widgets/text_field_widget.dart';
import 'package:bar_bros_user/pages/berbers_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final TextEditingController _searchController = TextEditingController();

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
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
        child: SingleChildScrollView(
          child: Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Nima qidiryapsiz ?",
                style: TextStyle(
                  fontFamily: "inter",
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Davom etish uchun xizmat toifasini tanlang",
                style: TextStyle(color: Colors.grey),
              ),
              TextFieldWidget(
                controller: _searchController,
                prefixIcon: Icon(Icons.search),
                hint: "Xizmatlarni qidirish",
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Ommabop xizmatlar"),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Barchasini ko''rish",
                      style: TextStyle(color: AppColors.yellow),
                    ),
                  ),
                ],
              ),
              GridView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BarbersPage()),
                      );
                    },
                    child: CommonServicesWidget(
                      title: 'Soch kesish',
                      subtitle: 'Klassik va Zamonaviy',
                      icon: Iconsax.scissor_1,
                    ),
                  ),
                  CommonServicesWidget(
                    title: 'Soch rangi',
                    subtitle: "Profession bo'yoq",
                    icon: Iconsax.mirror,
                    iconBackgroundColor: Color(0XFF678DF4),
                    gradientColors: [Color(0XFF3E79F3), Color(0XFF4F47E5)],
                  ),
                  CommonServicesWidget(
                    title: 'Yuz',
                    subtitle: 'Parvarish qilish',
                    icon: Iconsax.lovely,
                    iconBackgroundColor: Color(0XFFC56CDA),
                    gradientColors: [Color(0XFFB04EE4), Color(0XFFDC2777)],
                  ),
                  CommonServicesWidget(
                    title: 'Soqolni Kesish',
                    subtitle: 'Shakil va usul',
                    icon: Iconsax.profile_2user,
                    iconBackgroundColor: Color(0XFF41BEBB),
                    gradientColors: [Color(0XFF10B2A8), Color(0XFF0991B2)],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
