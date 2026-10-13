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
  final String? selectedSize;
  final int? selectedColor;
  final int quantity;
  final int activeImageIndex;
  final bool isFavorite;

  const ProductDetailLoaded({
    required this.product,
    this.selectedSize,
    this.selectedColor,
    this.quantity = 1,
    this.activeImageIndex = 0,
    this.isFavorite = false,
  });

  ProductDetailLoaded copyWith({
    ProductEntity? product,
    String? selectedSize,
    int? selectedColor,
    int? quantity,
    int? activeImageIndex,
    bool? isFavorite,
  }) {
    return ProductDetailLoaded(
      product: product ?? this.product,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      quantity: quantity ?? this.quantity,
      activeImageIndex: activeImageIndex ?? this.activeImageIndex,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        product,
        selectedSize,
        selectedColor,
        quantity,
        activeImageIndex,
        isFavorite,
      ];
}

class ProductDetailError extends ProductDetailState {
  final String message;

  const ProductDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
