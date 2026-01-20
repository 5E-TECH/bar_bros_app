import 'package:bar_bros_user/core/widgets/elevated_button_widget.dart';
import 'package:bar_bros_user/core/widgets/text_field_widget.dart';
import 'package:bar_bros_user/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bar_bros_user/location_premission_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WriteNamePage extends StatefulWidget {
  const WriteNamePage({super.key});

  @override
  State<WriteNamePage> createState() => _WriteNamePageState();
}

class _WriteNamePageState extends State<WriteNamePage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LocationPermissionPage()),
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(children: [Text("ismingizni_kiriting".tr())]),
                TextFieldWidget(
                  controller: _nameController,
                  enabled: !isLoading,
                ),
                SizedBox(height: 20.h),
                if (isLoading)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: CircularProgressIndicator(),
                  ),
                ElevatedButtonWidget(
                  text: isLoading ? "saqlanmoqda".tr() : "saqlash".tr(),
                  onPressed: isLoading
                      ? null
                      : () {
                          final name = _nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("ismingizni_kiriting".tr()),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          context.read<AuthBloc>().add(SetFullNameEvent(name));
                        },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
