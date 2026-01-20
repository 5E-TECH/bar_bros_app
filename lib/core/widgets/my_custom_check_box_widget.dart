import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MyCustomCheckbox extends StatefulWidget {
  final Widget? text;

  const MyCustomCheckbox({super.key, this.text});

  @override
  State<MyCustomCheckbox> createState() => _MyCustomCheckboxState();
}

class _MyCustomCheckboxState extends State<MyCustomCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: isChecked,
          activeColor: const Color(0xFFD2691E),
          checkColor: Colors.white,
          side: const BorderSide(color: Colors.grey, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (bool? value) {
            setState(() {
              isChecked = value ?? false;
            });
          },
        ),
        Expanded(child: widget.text ?? defaultRichText()),
      ],
    );
  }

  Widget defaultRichText() {
    return RichText(
      text: TextSpan(
        text: '${"men_2".tr()} ',
        children: [
          TextSpan(
            text: "maxfilik_siyosaati".tr(),
            style: TextStyle(color: AppColors.yellow),
          ),
          TextSpan(text: "va_shartlariga_roziman".tr()),
        ],
      ),
    );
  }
}
