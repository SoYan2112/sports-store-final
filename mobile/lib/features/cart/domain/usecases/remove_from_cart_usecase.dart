import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class RemoveFromCartUseCase {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  Future<List<CartItemEntity>> call({
    required List<CartItemEntity> currentItems,
    required String itemId,
  }) async {
    final items = currentItems.where((element) => element.id != itemId).toList();
    await repository.saveCartItems(items);
    return items;
  }
}

