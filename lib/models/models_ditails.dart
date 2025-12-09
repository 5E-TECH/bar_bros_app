import 'package:flutter/material.dart';

class Service {
  final String name;
  final double price;
  final String duration;
  final IconData icon;
  final Color color;

  Service({
    required this.name,
    required this.price,
    required this.duration,
    required this.icon,
    required this.color,
  });
}

class Master {
  final String name;
  final String surname;
  final double rating;
  final int reviewCount;
  final String imageUrl;

  Master({
    required this.name,
    required this.surname,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
  });
}

class Review {
  final String userName;
  final double rating;
  final String comment;
  final String date;
  final String imageUrl;

  Review({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    required this.imageUrl,
  });
}
