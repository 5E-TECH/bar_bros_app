import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  final String currentName;
  final String currentPhoneNumber;

  const EditProfilePage({
    super.key,
    required this.currentName,
    required this.currentPhoneNumber,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const String _keyFirstName = 'profile_first_name';
  static const String _keyLastName = 'profile_last_name';
  static const String _keyBirthDate = 'profile_birth_date';
  static const String _keyGender = 'profile_gender';
  static const String _keyPhone = 'profile_phone';
  static const String _keyImagePath = 'profile_image_path';

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _birthDateController;
  late TextEditingController _phoneController;
  
  String _selectedGender = 'Erkak'; // Default: Male
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    
    // Split the current name into first and last name
    final nameParts = widget.currentName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    
    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _birthDateController = TextEditingController();
    _phoneController = TextEditingController(text: widget.currentPhoneNumber);

    _loadSavedProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final firstName = prefs.getString(_keyFirstName);
    final lastName = prefs.getString(_keyLastName);
    final birthDate = prefs.getString(_keyBirthDate);
    final gender = prefs.getString(_keyGender);
    final phone = prefs.getString(_keyPhone);
    final imagePath = prefs.getString(_keyImagePath);

    setState(() {
      if (firstName != null && firstName.isNotEmpty) {
        _firstNameController.text = firstName;
      }
      if (lastName != null && lastName.isNotEmpty) {
        _lastNameController.text = lastName;
      }
      if (birthDate != null && birthDate.isNotEmpty) {
        _birthDateController.text = birthDate;
      }
      if (gender != null && gender.isNotEmpty) {
        _selectedGender = gender;
      }
      if (phone != null && phone.isNotEmpty) {
        _phoneController.text = phone;
      }
      if (imagePath != null && imagePath.isNotEmpty) {
        _profileImage = File(imagePath);
      }
    });
  }

  Future<void> _saveProfileLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyFirstName,
      _firstNameController.text.trim(),
    );
    await prefs.setString(
      _keyLastName,
      _lastNameController.text.trim(),
    );
    await prefs.setString(
      _keyBirthDate,
      _birthDateController.text.trim(),
    );
    await prefs.setString(
      _keyGender,
      _selectedGender,
    );
    await prefs.setString(
      _keyPhone,
      _phoneController.text.trim(),
    );
    if (_profileImage != null) {
      await prefs.setString(_keyImagePath, _profileImage!.path);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Rasmni yuklashda xatolik".tr())),
      );
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.yellow,
              onPrimary: Colors.white,
              surface: isDark ? AppColors.containerDark : Colors.white,
              onSurface: isDark ? Colors.white : Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final newName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

      _saveProfileLocal();

      // Update the name in the auth bloc
      context.read<AuthBloc>().add(SetFullNameEvent(newName));
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Profil muvaffaqiyatli yangilandi".tr()),
          backgroundColor: AppColors.yellow,
        ),
      );
      
      // Navigate back
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.primaryDark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final fieldBackgroundColor =
        isDark ? AppColors.containerDark : AppColors.containerLight;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.grey.withValues(alpha: 0.2);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "edit_profile_title".tr(),
          style: TextStyle(
            color: textColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image Section
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.gradient1, AppColors.gradient2],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: AppColors.yellow.withValues(alpha: 0.3),
                            width: 3,
                          ),
                        ),
                        child: _profileImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _profileImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Text(
                                  widget.currentName.isNotEmpty 
                                      ? widget.currentName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 48.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 36.w,
                            height: 36.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.yellow,
                              border: Border.all(
                                color: backgroundColor,
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 32.h),

                // First Name Field
                Text(
                  "Ism".tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _firstNameController,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: textColor,
                  ),
                  decoration: _inputDecoration(
                    hint: "Faxriddin".tr(),
                    fieldBackgroundColor: fieldBackgroundColor,
                    textColor: textColor,
                    borderColor: borderColor,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Ism bo'sh bo'lmasligi kerak".tr();
                    }
                    if (value.trim().length < 2) {
                      return "Ism juda qisqa".tr();
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20.h),

                // Last Name Field
                Text(
                  "Familiya".tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _lastNameController,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: textColor,
                  ),
                  decoration: _inputDecoration(
                    hint: "Maripov".tr(),
                    fieldBackgroundColor: fieldBackgroundColor,
                    textColor: textColor,
                    borderColor: borderColor,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Familiya bo'sh bo'lmasligi kerak".tr();
                    }
                    if (value.trim().length < 2) {
                      return "Familiya juda qisqa".tr();
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20.h),

                // Birth Date Field
                Text(
                  "birth_date".tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _birthDateController,
                  readOnly: true,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: textColor,
                  ),
                  decoration: _inputDecoration(
                    hint: "sana / oy / yil".tr(),
                    fieldBackgroundColor: fieldBackgroundColor,
                    textColor: textColor,
                    borderColor: borderColor,
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: textColor.withValues(alpha: 0.5),
                      size: 20.sp,
                    ),
                  ),
                  onTap: _selectBirthDate,
                ),

                SizedBox(height: 20.h),

                // Gender Selection
                Text(
                  "gender".tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGender = 'Erkak';
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            color: _selectedGender == 'Erkak'
                                ? AppColors.yellow.withValues(alpha: 0.15)
                                : fieldBackgroundColor,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: _selectedGender == 'Erkak'
                                  ? AppColors.yellow
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedGender == 'Erkak'
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: _selectedGender == 'Erkak'
                                    ? AppColors.yellow
                                    : textColor.withValues(alpha: 0.4),
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "male".tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: _selectedGender == 'Erkak'
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: _selectedGender == 'Erkak'
                                      ? AppColors.yellow
                                      : textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGender = 'Ayol';
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            color: _selectedGender == 'Ayol'
                                ? AppColors.yellow.withValues(alpha: 0.15)
                                : fieldBackgroundColor,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: _selectedGender == 'Ayol'
                                  ? AppColors.yellow
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedGender == 'Ayol'
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: _selectedGender == 'Ayol'
                                    ? AppColors.yellow
                                    : textColor.withValues(alpha: 0.4),
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "female".tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: _selectedGender == 'Ayol'
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: _selectedGender == 'Ayol'
                                      ? AppColors.yellow
                                      : textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Phone Number Field (Read-only)
                Text(
                  "Telefon raqam".tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _phoneController,
                  readOnly: true,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                  decoration: _inputDecoration(
                    hint: '',
                    fieldBackgroundColor:
                        fieldBackgroundColor.withValues(alpha: 0.6),
                    textColor: textColor,
                    borderColor: borderColor,
                  ),
                ),

                SizedBox(height: 40.h),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      "Saqlash".tr(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required Color fieldBackgroundColor,
    required Color textColor,
    required Color borderColor,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: fieldBackgroundColor,
      hintText: hint,
      hintStyle: TextStyle(
        color: textColor.withValues(alpha: 0.4),
      ),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: AppColors.yellow,
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 16.h,
      ),
    );
  }
}
