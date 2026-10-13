import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.brand,
    required super.price,
    super.originalPrice,
    required super.imageUrl,
    super.badge,
    super.rating = 4.8,
    super.reviewCount = 0,
    super.description = '',
    super.images = const [],
    super.category = 'Giày thể thao',
    super.stock = 15,
    super.sizes = const ['38', '39', '40', '41', '42', '43'],
    super.colors = const [0xFF1A1A1A, 0xFFFFFFFF, 0xFFFF6B00],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? 'Nike',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String? ?? '',
      badge: json['badge'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['imageUrl'] != null ? [json['imageUrl'] as String] : const []),
      category: json['category'] as String? ?? 'Giày thể thao',
      stock: (json['stock'] as num?)?.toInt() ?? 15,
      sizes: (json['sizes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['38', '39', '40', '41', '42', '43'],
      colors: (json['colors'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [0xFF1A1A1A, 0xFFFFFFFF, 0xFFFF6B00],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'badge': badge,
      'rating': rating,
      'reviewCount': reviewCount,
      'description': description,
      'images': images,
      'category': category,
      'stock': stock,
      'sizes': sizes,
      'colors': colors,
    };
  }
}
