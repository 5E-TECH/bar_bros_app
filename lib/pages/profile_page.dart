import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/features/theme/bloc/theme_bloc.dart';
import 'package:bar_bros_user/pages/add_card_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Card(
              child: ListTile(
                leading: BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) =>
                      Icon(state.isDark ? Icons.dark_mode : Icons.light_mode),
                ),
                title: Text("Tungi rejim"),
                trailing: BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return Switch(
                      value: state.isDark,
                      activeThumbColor: AppColors.yellow,
                      onChanged: (_) =>
                          context.read<ThemeBloc>().add(ToggleTheme()),
                    );
                  },
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.add_card),
                title: Text("Karta qo'shish"),
                trailing: IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddCardPage()),
                    );
                  },
                  icon: Icon(Icons.add),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
