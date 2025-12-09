import 'package:bar_bros_user/core/widgets/elevated_button_widget.dart';
import 'package:bar_bros_user/core/widgets/text_field_widget.dart';
import 'package:bar_bros_user/location_premission_page.dart';
import 'package:flutter/material.dart';
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.r),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [Text("Ismingizni Kiriting")]),
            TextFieldWidget(controller: _nameController),
            SizedBox(height: 20.h),
            ElevatedButtonWidget(
              text: "Saqlash",
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationPermissionPage(),
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
