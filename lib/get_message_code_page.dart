import 'dart:async';

import 'package:bar_bros_user/write_name_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'core/theme/app_colors.dart';
import 'core/widgets/elevated_button_widget.dart';


class SmsVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const SmsVerificationScreen({required this.phoneNumber});

  @override
  State<SmsVerificationScreen> createState() => _SmsVerificationScreenState();
}

// ✅ ADDED: with CodeAutoFill mixin for real SMS detection
class _SmsVerificationScreenState extends State<SmsVerificationScreen>
    with CodeAutoFill {

  List<TextEditingController> _controllers = List.generate(
    4,
        (_) => TextEditingController(),
  );
  List<FocusNode> _focusCodes = List.generate(4, (_) => FocusNode());
  int _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _listenForSms();
  }

  // Listen for incoming SMS
  Future<void> _listenForSms() async {
    try {
      await SmsAutoFill().listenForCode();
      print("🎧 Listening for SMS...");
    } catch (e) {
      print("❌ Error listening for SMS: $e");
      // Fallback to simulation for testing
      _simulateSmsAutoFill();
    }
  }

  // ✅ NEW METHOD: Automatically called when SMS arrives!
  @override
  void codeUpdated() {
    print("📨 SMS Code Received: ${code ?? 'null'}");

    if (code != null && code!.length >= 4) {
      setState(() {
        // Extract only digits from the SMS code
        String digitsOnly = code!.replaceAll(RegExp(r'[^0-9]'), '');

        // Fill the text fields automatically
        for (int i = 0; i < 4 && i < digitsOnly.length; i++) {
          _controllers[i].text = digitsOnly[i];
        }

        // Focus on last field and verify
        _focusCodes[3].requestFocus();
        FocusScope.of(context).unfocus();

        // Auto verify the code
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

  // Simulation fallback (for testing without real SMS)
  void _simulateSmsAutoFill() {
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        List<String> code = ["1", "2", "3", "4"];
        for (int i = 0; i < 4; i++) {
          _controllers[i].text = code[i];
        }
        _focusCodes[3].requestFocus();
      }
    });
  }

  // ✅ UPDATED: Added SMS listener cleanup
  @override
  void dispose() {
    _timer?.cancel();
    SmsAutoFill().unregisterListener();
    cancel(); // Cancel code listener from CodeAutoFill mixin
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
      print("✅ Code verified: $code");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WriteNamePage()),
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
      _listenForSms(); // ✅ Start listening for new SMS
      print("📤 Resending SMS code...");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Tasdiqlash kodini kiriting",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.phoneNumber,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              onTap: _resendCode,
              child: Text(
                _countdown > 0
                    ? 'Kodni qayta yuborish ($_countdown)'
                    : 'Kodni qayta yuborish',
                style: TextStyle(
                  color: _countdown > 0 ? Colors.grey : AppColors.yellow,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButtonWidget(
              text: "Kirish",
              onPressed: _verifySms,
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
                      'SMS kodi avtomatik aniqlanadi va to\'ldiriladi',
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
      ),
    );
  }
}
