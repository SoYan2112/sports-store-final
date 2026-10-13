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

  const ProductDetailLoaded({
    required this.product,
    this.quantity = 1,
  });

  ProductDetailLoaded copyWith({
    ProductEntity? product,
    int? quantity,
  }) {
    return ProductDetailLoaded(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product, quantity];
}

class ProductDetailError extends ProductDetailState {
  final String message;

  const ProductDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
