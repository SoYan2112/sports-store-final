import '../entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<List<CartItemEntity>> getCartItems();
  Future<void> saveCartItems(List<CartItemEntity> items);
  Future<void> clearCart();
}

