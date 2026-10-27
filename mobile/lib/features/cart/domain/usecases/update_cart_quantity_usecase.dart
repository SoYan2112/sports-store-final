import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class UpdateCartQuantityUseCase {
  final CartRepository repository;

  UpdateCartQuantityUseCase(this.repository);

  Future<List<CartItemEntity>> call({
    required List<CartItemEntity> currentItems,
    required String itemId,
    required int newQuantity,
  }) async {
    final items = List<CartItemEntity>.from(currentItems);
    final index = items.indexWhere((item) => item.id == itemId);

    if (index >= 0) {
      if (newQuantity <= 0) {
        items.removeAt(index);
      } else {
        items[index] = items[index].copyWith(quantity: newQuantity);
      }
      await repository.saveCartItems(items);
    }
    return items;
  }
}

