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
  final List<String> images;
  final String category;
  final int stock;
  final List<String> sizes;
  final List<int> colors;

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
    this.images = const [],
    this.category = 'Giày thể thao',
    this.stock = 15,
    this.sizes = const ['38', '39', '40', '41', '42', '43'],
    this.colors = const [0xFF1A1A1A, 0xFFFFFFFF, 0xFFFF6B00],
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  List<String> get galleryImages =>
      images.isNotEmpty ? images : [imageUrl];

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
        images,
        category,
        stock,
        sizes,
        colors,
      ];
}
