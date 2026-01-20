import 'package:bar_bros_user/features/category/presentation/bloc/category_bloc.dart';
import 'package:bar_bros_user/pages/category/widgets/gender_categories_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ManCategoriesPage extends StatelessWidget {
  const ManCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GenderCategoriesScreen(
      title: "Erkaklar uchun xizmatlar".tr(),
      loadEvent: const GetAllManCategoriesEvent(),
      emptyMessage: "Erkaklar uchun kategoriya topilmadi".tr(),
    );
  }
}
