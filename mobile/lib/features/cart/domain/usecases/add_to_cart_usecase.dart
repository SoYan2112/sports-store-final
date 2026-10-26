import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<List<CartItemEntity>> call({
    required List<CartItemEntity> currentItems,
    required CartItemEntity newItem,
  }) async {
    final items = List<CartItemEntity>.from(currentItems);
    final index = items.indexWhere((element) => element.id == newItem.id);

    if (index >= 0) {
      final existing = items[index];
      final newQuantity = existing.quantity + newItem.quantity;
      items[index] = existing.copyWith(quantity: newQuantity);
    } else {
      items.add(newItem);
    }

    await repository.saveCartItems(items);
    return items;
  }
}

