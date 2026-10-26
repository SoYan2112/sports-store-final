import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item_entity.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  final List<CartItemEntity> items;
  final CartItemEntity? lastAddedItem;
  final String? notificationMessage;

  const CartLoaded({
    required this.items,
    this.lastAddedItem,
    this.notificationMessage,
  });

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => items.isEmpty;

  CartLoaded copyWith({
    List<CartItemEntity>? items,
    CartItemEntity? lastAddedItem,
    String? notificationMessage,
    bool clearLastAdded = false,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      lastAddedItem: clearLastAdded ? null : (lastAddedItem ?? this.lastAddedItem),
      notificationMessage:
          clearLastAdded ? null : (notificationMessage ?? this.notificationMessage),
    );
  }

  @override
  List<Object?> get props => [items, lastAddedItem, notificationMessage];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}

