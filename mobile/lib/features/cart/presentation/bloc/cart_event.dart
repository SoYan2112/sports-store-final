import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item_entity.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCartEvent extends CartEvent {
  const LoadCartEvent();
}

class AddToCartEvent extends CartEvent {
  final CartItemEntity item;

  const AddToCartEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class UpdateCartItemQuantityEvent extends CartEvent {
  final String itemId;
  final int quantity;

  const UpdateCartItemQuantityEvent({
    required this.itemId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [itemId, quantity];
}

class RemoveCartItemEvent extends CartEvent {
  final String itemId;

  const RemoveCartItemEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}

class ResetCartEvent extends CartEvent {
  const ResetCartEvent();
}
