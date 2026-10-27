import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.productId,
    required super.name,
    required super.brand,
    required super.price,
    required super.imageUrl,
    required super.selectedSize,
    required super.selectedColor,
    required super.quantity,
    super.stock = 99,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? json['product_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? '',
      selectedSize: json['selectedSize']?.toString() ?? json['size']?.toString() ?? '',
      selectedColor: (json['selectedColor'] as num?)?.toInt() ??
          (json['color'] as num?)?.toInt() ??
          0xFF1A1A1A,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      stock: (json['stock'] as num?)?.toInt() ?? 99,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'brand': brand,
      'price': price,
      'imageUrl': imageUrl,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'quantity': quantity,
      'stock': stock,
    };
  }

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      id: entity.id,
      productId: entity.productId,
      name: entity.name,
      brand: entity.brand,
      price: entity.price,
      imageUrl: entity.imageUrl,
      selectedSize: entity.selectedSize,
      selectedColor: entity.selectedColor,
      quantity: entity.quantity,
      stock: entity.stock,
    );
  }
}

