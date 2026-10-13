import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

abstract class ProductDetailState extends Equatable {
  const ProductDetailState();

  @override
  List<Object?> get props => [];
}

class ProductDetailInitial extends ProductDetailState {
  const ProductDetailInitial();
}

class ProductDetailLoading extends ProductDetailState {
  final ProductEntity? cachedProduct;

  const ProductDetailLoading({this.cachedProduct});

  @override
  List<Object?> get props => [cachedProduct];
}

class ProductDetailLoaded extends ProductDetailState {
  final ProductEntity product;
  final int quantity;
  final String? selectedSize;
  final int? selectedColor;
  final List<String> outOfStockSizes;

  const ProductDetailLoaded({
    required this.product,
    this.quantity = 1,
    this.selectedSize,
    this.selectedColor,
    this.outOfStockSizes = const ['43'],
  });

  bool get canAddToCart =>
      selectedSize != null &&
      selectedColor != null &&
      !outOfStockSizes.contains(selectedSize) &&
      product.stock > 0;

  ProductDetailLoaded copyWith({
    ProductEntity? product,
    int? quantity,
    String? selectedSize,
    int? selectedColor,
    List<String>? outOfStockSizes,
  }) {
    return ProductDetailLoaded(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      outOfStockSizes: outOfStockSizes ?? this.outOfStockSizes,
    );
  }

  @override
  List<Object?> get props => [
        product,
        quantity,
        selectedSize,
        selectedColor,
        outOfStockSizes,
      ];
}

class ProductDetailError extends ProductDetailState {
  final String message;

  const ProductDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
