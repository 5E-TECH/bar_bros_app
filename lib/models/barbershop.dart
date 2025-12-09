class Barbershop {
  final String name;
  final String location;
  final double distance;
  final double rating;
  final String imageUrl;
  bool isFavorite;

  Barbershop({
    required this.name,
    required this.location,
    required this.distance,
    required this.rating,
    required this.imageUrl,
    this.isFavorite = false,
  });
}