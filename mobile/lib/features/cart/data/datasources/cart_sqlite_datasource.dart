import '../../../../core/database/app_database.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../models/cart_item_model.dart';
import 'cart_local_datasource.dart';

class CartSqliteDataSourceImpl implements CartLocalDataSource {
  final AppDatabase appDatabase;
  final LocalStorageService? storageService;

  CartSqliteDataSourceImpl({
    AppDatabase? appDatabase,
    this.storageService,
  }) : appDatabase = appDatabase ?? AppDatabase.instance;

  String? _getEffectiveUserId(String? userId) {
    return userId ?? storageService?.getUserId();
  }

  @override
  Future<List<CartItemModel>> getCartItems({String? userId}) async {
    final db = await appDatabase.database;
    final effectiveUserId = _getEffectiveUserId(userId);

    final List<Map<String, dynamic>> results;
    if (effectiveUserId != null && effectiveUserId.isNotEmpty) {
      results = await db.query(
        'cart_items',
        where: 'user_id = ?',
        whereArgs: [effectiveUserId],
      );
    } else {
      results = await db.query(
        'cart_items',
        where: 'user_id IS NULL OR user_id = ?',
        whereArgs: ['guest'],
      );
    }

    return results.map((row) {
      return CartItemModel(
        id: row['id'] as String,
        productId: row['product_id'] as String,
        name: row['product_name'] as String? ?? '',
        price: (row['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: row['image_url'] as String? ?? '',
        brand: row['brand'] as String? ?? '',
        selectedSize: row['selected_size'] as String? ?? '',
        selectedColor: (row['selected_color'] as num?)?.toInt() ?? 0xFF1A1A1A,
        quantity: (row['quantity'] as num?)?.toInt() ?? 1,
        stock: (row['stock'] as num?)?.toInt() ?? 15,
      );
    }).toList();
  }

  @override
  Future<void> saveCartItems(
    List<CartItemModel> items, {
    String? userId,
  }) async {
    final db = await appDatabase.database;
    final effectiveUserId = _getEffectiveUserId(userId) ?? 'guest';

    await db.transaction((txn) async {
      // 1. Xóa giỏ hàng cũ của user này
      await txn.delete(
        'cart_items',
        where: 'user_id = ?',
        whereArgs: [effectiveUserId],
      );

      // 2. Chèn danh sách món mới vào SQLite
      for (final item in items) {
        await txn.insert('cart_items', {
          'id': item.id,
          'user_id': effectiveUserId,
          'product_id': item.productId,
          'product_name': item.name,
          'price': item.price,
          'image_url': item.imageUrl,
          'brand': item.brand,
          'selected_size': item.selectedSize,
          'selected_color': item.selectedColor,
          'quantity': item.quantity,
          'stock': item.stock,
        });
      }
    });
  }

  @override
  Future<void> clearCart({String? userId}) async {
    final db = await appDatabase.database;
    final effectiveUserId = _getEffectiveUserId(userId) ?? 'guest';

    await db.delete(
      'cart_items',
      where: 'user_id = ?',
      whereArgs: [effectiveUserId],
    );
  }
}
