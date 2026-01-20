class Barbershop {
  final String id;
  final String? serviceId;
  final String name;
  final String location;
  final double distance;
  final double rating;
  final String imageUrl;
  final String openTime;
  final String closeTime;
  final String description;
  final String phoneNumber;
  final String status;
  final int price;
  bool isFavorite;

  Barbershop({
    this.id = '',
    this.serviceId,
    required this.name,
    required this.location,
    required this.distance,
    required this.rating,
    required this.imageUrl,
    this.openTime = '09:00',
    this.closeTime = '21:00',
    this.description = '',
    this.phoneNumber = '',
    this.status = 'active',
    this.price = 0,
    this.isFavorite = false,
  });
}
