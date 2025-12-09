import 'package:bar_bros_user/core/widgets/elevated_button_widget.dart';
import 'package:bar_bros_user/core/widgets/text_field_widget.dart';
import 'package:bar_bros_user/get_message_code_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController _phoneEditingController = TextEditingController();
  TextEditingController _passwordEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          spacing: 22,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                spacing: 5,
                children: [
                  SvgPicture.asset(
                    "assets/svgs/Vector.svg",
                    width: 40.w,
                    height: 40.h,
                  ),
                  Text(
                    "BarBros",
                    style: TextStyle(
                      fontSize: 48,
                      fontFamily: "inter",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(color: Colors.grey),
                    "Ilovamiz bilan tanishish uchun hisob  \nyarating yoki tizimga kiring",
                  ),
                ],
              ),
            ),
            Text("Telefon raqam"),
            TextFieldWidget(
              controller: _phoneEditingController,
              keyboardType: TextInputType.phone,
            ),
            ElevatedButtonWidget(
              text: "Kirish",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SmsVerificationScreen(phoneNumber: _phoneEditingController.text),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
