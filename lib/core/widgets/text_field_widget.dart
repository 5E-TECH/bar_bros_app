import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.keyboardType,
    this.isPassword = false,
    this.prefixIcon,
    this.onChanged,
    this.enabled = false,
    this.inputFormatters,
    this.validator,
    this.filled,
    this.fillColor,

  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool isPassword;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;
  final bool? enabled;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? validator;
  final bool? filled;
  final Color? fillColor;

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: widget.enabled,
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      obscureText: widget.isPassword ? _hidePassword : false,
      cursorColor: AppColors.yellow,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        hintStyle: const TextStyle(color: Colors.grey),
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: widget.prefixIcon,

        filled: widget.filled,
        fillColor: widget.fillColor,

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 5.w),
        constraints: BoxConstraints(minHeight: 30.h, maxHeight: 40.h),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.yellow, width: 2),
        ),

        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _hidePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.yellow,
                ),
                onPressed: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
              )
            : null,
      ),
    );
  }
}
