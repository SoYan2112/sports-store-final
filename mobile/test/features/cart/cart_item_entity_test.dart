import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/cart/data/models/cart_item_model.dart';
import 'package:mobile/features/cart/domain/entities/cart_item_entity.dart';

void main() {
  group('CartItemEntity & CartItemModel', () {
    final expectedId = CartItemEntity.generateId('p1', '42', 0xFF1A1A1A);

    final item = CartItemEntity(
      id: expectedId,
      productId: 'p1',
      name: 'Nike Joyride Run',
      brand: 'Nike',
      price: 2000000,
      imageUrl: 'https://example.com/shoe.png',
      selectedSize: '42',
      selectedColor: 0xFF1A1A1A,
      quantity: 2,
      stock: 10,
    );

    test('generateId creates unique key from productId, size, color', () {
      final id = CartItemEntity.generateId('p1', '42', 0xFF1A1A1A);
      expect(id, 'p1_42_${0xFF1A1A1A}');
    });

    test('totalPrice calculates price * quantity', () {
      expect(item.totalPrice, 4000000);
    });

    test('copyWith updates properties properly', () {
      final updated = item.copyWith(quantity: 3);
      expect(updated.quantity, 3);
      expect(updated.id, item.id);
      expect(updated.name, item.name);
    });

    test('CartItemModel toJson & fromJson serialization', () {
      final model = CartItemModel.fromEntity(item);
      final json = model.toJson();

      expect(json['id'], expectedId);
      expect(json['productId'], 'p1');
      expect(json['price'], 2000000.0);
      expect(json['quantity'], 2);

      final fromJson = CartItemModel.fromJson(json);
      expect(fromJson.id, model.id);
      expect(fromJson.name, model.name);
      expect(fromJson.price, model.price);
      expect(fromJson.quantity, model.quantity);
      expect(fromJson.selectedSize, model.selectedSize);
    });
  });
}
