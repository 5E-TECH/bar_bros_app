import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:bar_bros_user/core/widgets/elevated_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  String cardNumber = "";
  String expiryDate = "";
  String cardHolderName = "";
  String cvvCode = "";
  bool isCvvFocused = false;
  bool useGlassmorphism = true;
  bool useBackgroundImage = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "BarBros",
          style: TextStyle(fontFamily: "inter", fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: IconButton.outlined(
              onPressed: () {},
              icon: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      body: Column(
        spacing: 5,
        children: [
          CreditCardWidget(
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cardHolderName: cardHolderName,
            cvvCode: cvvCode,
            showBackView: isCvvFocused,
            obscureCardNumber: true,
            obscureCardCvv: true,
            isHolderNameVisible: true,
            height: 200.h,
            textStyle:  TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            width: MediaQuery.of(context).size.width,
            isChipVisible: true,
            isSwipeGestureEnabled: true,
            animationDuration: const Duration(milliseconds: 1000),
            cardBgColor: const Color(0xFF2E3A59),
            glassmorphismConfig: useGlassmorphism
                ? Glassmorphism(
                    blurX: 8.0,
                    blurY: 16.0,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                         Color(0xFF2E3A59).withValues(alpha: 0.8),
                         Color(0xFF1a2332).withValues(alpha: 0.8),
                      ],
                    ),
                  )
                : null,
            backgroundImage: useBackgroundImage
                ? 'assets/images/card.jpg'
                : null,
            onCreditCardWidgetChange: (CreditCardBrand brand) {
            },
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CreditCardForm(
                    formKey: formKey,
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cvvCode: cvvCode,
                    onCreditCardModelChange: onCreditCardModelChange,
                    obscureCvv: true,
                    obscureNumber: false,
                    isHolderNameVisible: true,
                    isCardNumberVisible: true,
                    isExpiryDateVisible: true,
                    enableCvv: true,
                    cvvValidationMessage: 'CVV ni to\'g\'ri kiriting',
                    dateValidationMessage: 'Tugash sanasini to\'g\'ri kiriting',
                    numberValidationMessage:
                        'Karta raqamini to\'g\'ri kiriting',
                    cardNumberValidator: (String? cardNumber) {
                      if (cardNumber == null || cardNumber.isEmpty) {
                        return 'Karta raqamini kiriting';
                      }
                      if (cardNumber.replaceAll(' ', '').length < 13) {
                        return 'Karta raqami kamida 13 ta raqamdan iborat';
                      }
                      return null;
                    },
                    expiryDateValidator: (String? expiryDate) {
                      if (expiryDate == null || expiryDate.isEmpty) {
                        return 'Tugash sanasini kiriting';
                      }
                      return null;
                    },
                    cvvValidator: (String? cvv) {
                      if (cvv == null || cvv.isEmpty) {
                        return 'CVV ni kiriting';
                      }
                      if (cvv.length < 3) {
                        return 'CVV 3 ta raqamdan iborat';
                      }
                      return null;
                    },
                    cardHolderValidator: (String? cardHolderName) {
                      if (cardHolderName == null || cardHolderName.isEmpty) {
                        return 'Karta egasi nomini kiriting';
                      }
                      return null;
                    },
                    inputConfiguration: InputConfiguration(
                      cardNumberTextStyle: TextStyle(
                        fontSize: 16.sp,
                      ),
                      expiryDateTextStyle: TextStyle(
                        fontSize: 16.sp,
                      ),
                      cvvCodeTextStyle: TextStyle(
                        fontSize: 16.sp,
                      ),
                      cardHolderTextStyle: TextStyle(
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          'Glassmorphism',
                        ),
                        Switch(
                          value: useGlassmorphism,
                          activeThumbColor: AppColors.yellow,
                          onChanged: (value) {
                            setState(() {
                              useGlassmorphism = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          'Karta rasmi',
                        ),
                        Switch(
                          value: useBackgroundImage,
                          activeThumbColor: AppColors.yellow,
                          onChanged: (value) {
                            setState(() {
                              useBackgroundImage = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h,),
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 16.w),
                    child: ElevatedButtonWidget(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Karta muvaffaqiyatli saqlandi'),
                            backgroundColor: AppColors.yellow,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
