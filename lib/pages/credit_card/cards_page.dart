import 'dart:convert';

import 'package:bar_bros_user/core/theme/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_card_page.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  static const String _cardsKey = 'saved_cards';
  List<Map<String, String>> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cardsKey);
    if (!mounted) return;
    setState(() {
      _cards = _decodeCards(raw);
      _isLoading = false;
    });
  }

  List<Map<String, String>> _decodeCards(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Map<String, String>.from(item as Map))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _openAddCard({int? index}) async {
    final card = index == null ? null : _cards[index];
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddCardPage(
          initialCardNumber: card?['cardNumber'] ?? '',
          initialExpiryDate: card?['expiryDate'] ?? '',
          initialCardHolderName: card?['cardHolderName'] ?? '',
          cardIndex: index,
        ),
      ),
    );
    if (result == true) {
      _loadCards();
    }
  }

  Future<void> _deleteCard(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _cards.removeAt(index);
    await prefs.setString(_cardsKey, jsonEncode(_cards));
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Karta o'chirildi".tr()),
          backgroundColor: AppColors.yellow,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
    }
  }

  void _showDeleteDialog(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.primaryDark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          "Kartani o'chirish".tr(),
          style: TextStyle(color: textColor),
        ),
        content: Text(
          "Ushbu kartani o'chirishni xohlaysizmi?".tr(),
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Bekor qilish".tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCard(index);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text("O'chirish".tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? Colors.white : AppColors.primaryDark;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          "cards_title".tr(),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton.outlined(
            onPressed: () => _openAddCard(),
            icon: const Icon(Icons.add),
            tooltip: "Karta qo'shish".tr(),
          ),
          SizedBox(width: 16.w),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: _cards.isEmpty
            ? _EmptyCards(
          onAdd: _openAddCard,
          textColor: textColor,
        )
            : ListView.builder(
          itemCount: _cards.length,
          itemBuilder: (context, index) {
            final card = _cards[index];
            return _CardItem(
              card: card,
              isDark: isDark,
              onTap: () => _openAddCard(index: index),
              onDelete: () => _showDeleteDialog(index),
            );
          },
        ),
      ),
    );
  }
}

class _CardItem extends StatelessWidget {
  final Map<String, String> card;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CardItem({
    required this.card,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  String _maskCardNumber(String number) {
    final digits = number.replaceAll(RegExp(r'\s+'), '');
    if (digits.length <= 8) return number;

    final first4 = digits.substring(0, 4);
    final last4 = digits.substring(digits.length - 4);
    return '$first4 •••• •••• $last4';
  }

  String _getCardType(String number) {
    final digits = number.replaceAll(RegExp(r'\s+'), '');
    if (digits.startsWith('8600')) return 'Humo';
    if (digits.startsWith('9860')) return 'Uzcard';
    if (digits.startsWith('4')) return 'Visa';
    if (digits.startsWith('5')) return 'Mastercard';
    return 'Card';
  }

  Color _getCardGradientStart(String type) {
    switch (type) {
      case 'Humo':
        return const Color(0xFF00B4D8);
      case 'Uzcard':
        return const Color(0xFF4361EE);
      case 'Visa':
        return const Color(0xFF1A1F71);
      case 'Mastercard':
        return const Color(0xFFEB001B);
      default:
        return const Color(0xFF2E3A59);
    }
  }

  Color _getCardGradientEnd(String type) {
    switch (type) {
      case 'Humo':
        return const Color(0xFF0077B6);
      case 'Uzcard':
        return const Color(0xFF3A0CA3);
      case 'Visa':
        return const Color(0xFF0D47A1);
      case 'Mastercard':
        return const Color(0xFFF79E1B);
      default:
        return const Color(0xFF1A2332);
    }
  }

  @override
  Widget build(BuildContext context) {
    final number = card['cardNumber'] ?? '';
    final holder = card['cardHolderName'] ?? '';
    final expiry = card['expiryDate'] ?? '';
    final cardType = _getCardType(number);

    return Dismissible(
      key: Key(number),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        onDelete();
        return false;
      },
      background: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getCardGradientStart(cardType),
                _getCardGradientEnd(cardType),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: _getCardGradientStart(cardType).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // Card content
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            cardType,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.contactless,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 28.sp,
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      _maskCardNumber(number),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "KARTA EGASI".tr(),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                holder.isEmpty ? "—" : holder.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "AMAL QILADI".tr(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              expiry,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCards extends StatelessWidget {
  final VoidCallback onAdd;
  final Color textColor;

  const _EmptyCards({
    required this.onAdd,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.yellow.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.credit_card_outlined,
                size: 64.sp,
                color: AppColors.yellow,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "no_cards_title".tr(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "no_cards_body".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: textColor.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            // ElevatedButton.icon(
            //   onPressed: onAdd,
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: AppColors.yellow,
            //     foregroundColor: Colors.white,
            //     elevation: 0,
            //     padding: EdgeInsets.symmetric(
            //       horizontal: 32.w,
            //       vertical: 16.h,
            //     ),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12.r),
            //     ),
            //   ),
            //   icon: const Icon(Icons.add, size: 20),
            //   label: Text(
            //     "add_card_action".tr(),
            //     style: TextStyle(
            //       fontSize: 15.sp,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}