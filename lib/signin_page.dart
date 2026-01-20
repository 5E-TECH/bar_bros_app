import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/core/widgets/elevated_button_widget.dart';
import 'package:bar_bros_user/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bar_bros_user/get_message_code_page.dart'; // Assuming this is SmsVerificationScreen path
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart'; // ← New import
import 'package:flutter/services.dart';

/// Formats phone number as: XX XXX XX XX
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digitsOnly.length && i < 9; i++) {
      if (i == 2 || i == 5 || i == 7) {
        buffer.write(' ');
      }
      buffer.write(digitsOnly[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String _phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SmsVerificationScreen(
                  phoneNumber: '+998$_phoneNumber',
                  userId: state.userId,
                  isNewUser: state.isNew,
                ),
              ),
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: SizedBox(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          SizedBox(height: 5.h),
                          SvgPicture.asset(
                            "assets/svgs/Vector.svg",
                            width: 40.w,
                            height: 40.h,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "StyleUp",
                            style: TextStyle(
                              fontSize: 48,
                              fontFamily: "inter",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                            "Ilovamiz bilan tanishish uchun hisob  \nyarating yoki tizimga kiring"
                                .tr(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 22.h),
                    Text("telefon_raqam".tr()),
                    SizedBox(height: 8.h),
                    IntlPhoneField(
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.yellow, width: 2),
                        ),
                      ),
                      initialCountryCode: 'UZ',
                      disableLengthCheck: true,
                      enabled: !isLoading,
                      inputFormatters: [PhoneNumberFormatter()],
                      onChanged: (phone) {
                        _phoneNumber = phone.number.replaceAll(' ', '');
                      },
                    ),
                    SizedBox(height: 22.h),
                    ElevatedButtonWidget(
                      text: isLoading ? "yuklanmoqda".tr() : "kirish".tr(),
                      onPressed: isLoading
                          ? null
                          : () {
                        if (_phoneNumber.isEmpty || _phoneNumber.length < 9) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("togri_telefon_raqam_kiriting".tr()),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        context.read<AuthBloc>().add(
                          RegisterEvent('+998$_phoneNumber'),
                        );
                      },
                    ),
                    if (isLoading)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.h),
                          child: CircularProgressIndicator(color: AppColors.yellow),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
