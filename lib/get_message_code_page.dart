import 'dart:async';

import 'package:bar_bros_user/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bar_bros_user/location_premission_page.dart';
import 'package:bar_bros_user/write_name_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'core/theme/app_colors.dart';
import 'core/widgets/elevated_button_widget.dart';

class SmsVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String userId;
  final bool isNewUser;

  const SmsVerificationScreen({
    required this.phoneNumber,
    required this.userId,
    required this.isNewUser,
    super.key,
  });

  @override
  State<SmsVerificationScreen> createState() => _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends State<SmsVerificationScreen>
    with CodeAutoFill {
  List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  List<FocusNode> _focusCodes = List.generate(4, (_) => FocusNode());
  int _countdown = 180;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _listenForSms();
  }

  Future<void> _listenForSms() async {
    try {
      await SmsAutoFill().listenForCode();
      print("🎧 Listening for SMS...");
    } catch (e) {
      print("❌ Error listening for SMS: $e");
    }
  }

  @override
  void codeUpdated() {
    print("📨 SMS Code Received: ${code ?? 'null'}");

    if (code != null && code!.length >= 4) {
      setState(() {
        String digitsOnly = code!.replaceAll(RegExp(r'[^0-9]'), '');

        for (int i = 0; i < 4 && i < digitsOnly.length; i++) {
          _controllers[i].text = digitsOnly[i];
        }

        _focusCodes[3].requestFocus();
        FocusScope.of(context).unfocus();

        _verifySms();
      });
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    SmsAutoFill().unregisterListener();
    cancel();
    _controllers.forEach((controller) => controller.dispose());
    _focusCodes.forEach((node) => node.dispose());
    super.dispose();
  }

  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusCodes[index + 1].requestFocus();
    }
    if (index == 3 && value.isNotEmpty) {
      FocusScope.of(context).unfocus();
      _verifySms();
    }
  }

  void _verifySms() {
    String code = _controllers.map((c) => c.text).join();
    if (code.length == 4) {
      context.read<AuthBloc>().add(
        VerifyCodeEvent(
          phoneNumber: widget.phoneNumber,
          code: code,
          isNewUser: widget.isNewUser,
        ),
      );
    }
  }

  void _resendCode() {
    if (_countdown == 0) {
      setState(() {
        _countdown = 240;
      });
      _startCountdown();
      _controllers.forEach((c) => c.clear());
      _listenForSms();
      context.read<AuthBloc>().add(RegisterEvent(widget.phoneNumber));
    }
  }

  String _formatTime(int seconds) {
    int min = seconds ~/ 60;
    int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is VerifySuccess) {
            // VerifySuccess means user needs to complete profile (set fullname)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WriteNamePage()),
            );
          } else if (state is AuthAuthenticated) {
            // AuthAuthenticated means user profile is complete
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => LocationPermissionPage(),
              ),
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is RegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("kod_qayta_yuborildi".tr()),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "tasdiqlash_kodini_kiriting".tr(),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.phoneNumber,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      width: 60.w,
                      height: 60.h,
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      child: TextField(
                        cursorColor: AppColors.yellow,
                        controller: _controllers[index],
                        focusNode: _focusCodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        enabled: !isLoading,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: AppColors.yellow),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: AppColors.yellow,
                              width: 2,
                            ),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _onCodeChanged(index, value),
                        onTap: () {
                          if (_controllers[index].text.isNotEmpty) {
                            _controllers[index].selection =
                                TextSelection.fromPosition(
                                  TextPosition(
                                    offset: _controllers[index].text.length,
                                  ),
                                );
                          }
                        },
                      ),
                    );
                  }),
                ),
                GestureDetector(
                  onTap: isLoading ? null : _resendCode,
                  child: Text(
                    _countdown > 0
                        ? tr(
                            'resend_code_timer',
                            namedArgs: {
                              'time': _formatTime(_countdown),
                            },
                          )
                        : "kodni_qayta_yuborish".tr(),
                    style: TextStyle(
                      color: _countdown > 0 || isLoading
                          ? Colors.grey
                          : AppColors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isLoading)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: CircularProgressIndicator(color: AppColors.yellow),
                  ),
                ElevatedButtonWidget(
                  text: isLoading ? "tekishirilmoqda".tr() : "kirish".tr(),
                  onPressed: isLoading ? null : _verifySms,
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "sms_kodi_avtomatik_aniqlanadi_va_toldiriladi".tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
