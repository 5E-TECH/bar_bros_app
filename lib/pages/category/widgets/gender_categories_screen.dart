import 'package:bar_bros_user/core/constants/api_constants.dart';
import 'package:bar_bros_user/core/di/ingector.dart';
import 'package:bar_bros_user/features/category/domain/entities/category.dart';
import 'package:bar_bros_user/features/category/presentation/bloc/category_bloc.dart';
import 'package:bar_bros_user/barbershop_services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GenderCategoriesScreen extends StatelessWidget {
  final String title;
  final CategoryEvent loadEvent;
  final String emptyMessage;

  const GenderCategoriesScreen({
    super.key,
    required this.title,
    required this.loadEvent,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CategoryBloc>()..add(loadEvent),
      child: _GenderCategoriesView(
        title: title,
        loadEvent: loadEvent,
        emptyMessage: emptyMessage,
      ),
    );
  }
}

class _GenderCategoriesView extends StatelessWidget {
  final String title;
  final CategoryEvent loadEvent;
  final String emptyMessage;

  const _GenderCategoriesView({
    required this.title,
    required this.loadEvent,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title,style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: SafeArea(
        child: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is CategoryError) {
              return Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<CategoryBloc>().add(loadEvent),
                      child: Text("qayta_urinish".tr()),
                    ),
                  ],
                ),
              );
            } else if (state is CategoryLoaded) {
              final visibleCategories =
                  state.categories.where((c) => !c.isDeleted).toList();
              if (visibleCategories.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Text(
                      emptyMessage,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.all(16.w),
                child: GridView.builder(
                  itemCount: visibleCategories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final category = visibleCategories[index];
                    return _CategoryTile(
                      category: category,
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;

  const _CategoryTile({
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadowColor =
        isDark ? Colors.black.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.18);
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BarbershopServices(
              categoryId: category.id,
              categoryName: category.name,
              categoryType: category.categoryType,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: _buildImage(),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(bottom: 8.h, right: 8.w, left: 8.w),
            child: Text(
              category.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (category.img.isEmpty) {
      return Container(
        child: Icon(
          Icons.category,
          size: 32.r,
        ),
      );
    }

    final lowerUrl = category.img.toLowerCase();
    final fullUrl = category.img.startsWith('http')
        ? category.img
        : '${Constants.imageBaseUrl}${category.img}';

    if (lowerUrl.endsWith('.svg')) {
      return SvgPicture.network(
        fullUrl,
        fit: BoxFit.cover,
        placeholderBuilder: (context) => Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Image.network(
      fullUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        child: Icon(
          Icons.broken_image_outlined,
          size: 32.r,
        ),
      ),
    );
  }
}
