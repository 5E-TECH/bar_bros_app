import 'package:equatable/equatable.dart';

class BarberShopQuery extends Equatable {
  final int limit;
  final int page;

  const BarberShopQuery({
    this.limit = 10,
    this.page = 1,
  });

  @override
  List<Object?> get props => [limit, page];
}
