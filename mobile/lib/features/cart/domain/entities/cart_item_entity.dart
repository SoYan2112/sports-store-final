import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String id;
  final String productId;
  final String name;
  final String brand;
  final double price;
  final String imageUrl;
  final String selectedSize;
  final int selectedColor;
  final int quantity;
  final int stock;

  const CartItemEntity({
    required this.id,
    required this.productId,
    required this.name,
    required this.brand,
    required this.price,
    required this.imageUrl,
    required this.selectedSize,
    required this.selectedColor,
    required this.quantity,
    this.stock = 99,
  });

  /// Tạo ID duy nhất cho biến thể trong giỏ: productId_size_color
  static String generateId(String productId, String size, int color) {
    return '${productId}_${size}_$color';
  }

  double get totalPrice => price * quantity;

  CartItemEntity copyWith({
    String? id,
    String? productId,
    String? name,
    String? brand,
    double? price,
    String? imageUrl,
    String? selectedSize,
    int? selectedColor,
    int? quantity,
    int? stock,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      quantity: quantity ?? this.quantity,
      stock: stock ?? this.stock,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        name,
        brand,
        price,
        imageUrl,
        selectedSize,
        selectedColor,
        quantity,
        stock,
      ];
}

