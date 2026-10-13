import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String brand;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String? badge; // 'New', 'Hot', 'Sale', 'Best Seller'
  final double rating;
  final int reviewCount;
  final String description;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.badge,
    this.rating = 4.8,
    this.reviewCount = 0,
    this.description = '',
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  @override
  List<Object?> get props => [
        id,
        name,
        brand,
        price,
        originalPrice,
        imageUrl,
        badge,
        rating,
        reviewCount,
        description,
      ];
}
