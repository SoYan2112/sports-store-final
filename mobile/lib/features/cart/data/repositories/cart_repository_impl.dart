import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({required this.localDataSource});

  @override
  Future<List<CartItemEntity>> getCartItems() async {
    return await localDataSource.getCartItems();
  }

  @override
  Future<void> saveCartItems(List<CartItemEntity> items) async {
    final models = items.map((e) => CartItemModel.fromEntity(e)).toList();
    await localDataSource.saveCartItems(models);
  }

  @override
  Future<void> clearCart() async {
    await localDataSource.clearCart();
  }
}

