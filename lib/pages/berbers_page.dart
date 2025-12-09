import 'package:bar_bros_user/core/widgets/home_page_widgets/barbershop_card.dart';
import 'package:bar_bros_user/core/widgets/text_field_widget.dart';
import 'package:bar_bros_user/models/barbershop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BarbersPage extends StatefulWidget {
  const BarbersPage({super.key});

  @override
  State<BarbersPage> createState() => _BarbersPageState();
}

class _BarbersPageState extends State<BarbersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Barbershop> _allBarbershops = [
    Barbershop(
      name: 'BarberShop',
      location: 'Uzbekistan, Tashkent',
      distance: 1.2,
      rating: 4.8,
      imageUrl: 'assets/images/barber1.png',
      isFavorite: false,
    ),
    Barbershop(
      name: 'Rahmatullo Ergashev',
      location: 'Uzbekistan, Tashkent',
      distance: 1.2,
      rating: 4.8,
      imageUrl: 'assets/images/barber.png',
      isFavorite: true,
    ),
    Barbershop(
      name: 'Jumanazaar',
      location: 'Uzbekistan, Xorazm',
      distance: 1.2,
      rating: 4.8,
      imageUrl: 'assets/images/barber.png',
      isFavorite: true,
    ),
    Barbershop(
      name: 'BarberShop',
      location: 'Uzbekistan, Andijon',
      distance: 1.2,
      rating: 4.8,
      imageUrl: 'assets/images/barber.png',
      isFavorite: true,
    ),
    Barbershop(
      name: 'BarberShop',
      location: 'Uzbekistan, Andijon',
      distance: 1.2,
      rating: 4.8,
      imageUrl: 'assets/images/barber.png',
      isFavorite: true,
    ),
    Barbershop(
      name: 'BarberShop',
      location: 'Uzbekistan, Andijon',
      distance: 1.2,
      rating: 4.8,
      imageUrl: 'assets/images/barber.png',
      isFavorite: true,
    ),
    Barbershop(
      name: 'BarberShop',
      location: 'Uzbekistan, Andijon',
      distance: 1.2,
      rating: 4.8,
      imageUrl: 'assets/images/barber.png',
      isFavorite: true,
    ),
    Barbershop(
      name: 'BarberShop',
      location: 'Uzbekistan, XXorazm',
      distance: 1.2,
      rating: 4.8,
      imageUrl: 'assets/images/barber.png',
      isFavorite: true,
    ),
    Barbershop(
      name: 'BarberShop',
      location: 'Uzbekistan, Kokand',
      distance: 1.2,
      rating: 4.8,
      imageUrl: 'assets/images/barber.png',
      isFavorite: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFavorite(Barbershop shop) {
    final index = _allBarbershops.indexOf(shop);
    if (index != -1) {
      setState(() {
        _allBarbershops[index].isFavorite =
        !_allBarbershops[index].isFavorite;
      });
    }
  }

  List<Barbershop> get _filtered {
    if (_searchQuery.isEmpty) return _allBarbershops;

    return _allBarbershops.where((shop) {
      final query = _searchQuery.toLowerCase();
      return shop.name.toLowerCase().contains(query) ||
          shop.location.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextFieldWidget(
          controller: _searchController,
          prefixIcon: Icon(Icons.search),
          hint: "Sartaroshlarni qidirish",
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: _filtered.isEmpty
            ? Center(
          child: Text(
            "Sartaroshlar topilmadi!",
            style: TextStyle(fontSize: 18.sp),
          ),
        )
            : ListView.builder(
          itemCount: _filtered.length,
          itemBuilder: (context, index) {
            final barber = _filtered[index];
            return BarbershopCard(
              barbershop: barber,
              onFavoriteToggle: () => _toggleFavorite(barber),
            );
          },
        ),
      ),
    );
  }
}
