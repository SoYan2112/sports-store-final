import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/storage/local_storage_service.dart';
import 'package:mobile/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:mobile/features/cart/data/models/cart_item_model.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late CartLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockPrefs;
  late MockLocalStorageService mockStorageService;

  const testModel = CartItemModel(
    id: 'p1_42_4279934490',
    productId: 'p1',
    name: 'Nike Air Max',
    brand: 'Nike',
    price: 2500000,
    imageUrl: 'https://example.com/shoe.png',
    selectedSize: '42',
    selectedColor: 0xFF1A1A1A,
    quantity: 1,
    stock: 10,
  );

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockStorageService = MockLocalStorageService();
    dataSource = CartLocalDataSourceImpl(
      sharedPreferences: mockPrefs,
      storageService: mockStorageService,
    );
  });

  group('CartLocalDataSourceImpl User-scoped', () {
    test(
      'returns empty list when user is not logged in (userId is null)',
      () async {
        when(() => mockStorageService.getUserId()).thenReturn(null);

        final result = await dataSource.getCartItems();

        expect(result, isEmpty);
        verifyNever(() => mockPrefs.getString(any()));
      },
    );

    test('reads from user-specific key when user is logged in', () async {
      when(() => mockStorageService.getUserId()).thenReturn('user_123');
      when(() => mockPrefs.getString('sports_store_cart_items_user_user_123'))
          .thenReturn(
            '[{"id":"p1_42_4279934490","productId":"p1","name":"Nike Air Max","brand":"Nike","price":2500000,"imageUrl":"https://example.com/shoe.png","selectedSize":"42","selectedColor":4279934490,"quantity":1,"stock":10}]',
          );

      final result = await dataSource.getCartItems();

      expect(result.length, 1);
      expect(result.first.id, testModel.id);
      expect(result.first.name, testModel.name);
    });

    test('saves to user-specific key when saving cart items', () async {
      when(() => mockStorageService.getUserId()).thenReturn('user_123');
      when(
        () =>
            mockPrefs.setString('sports_store_cart_items_user_user_123', any()),
      ).thenAnswer((_) async => true);

      await dataSource.saveCartItems([testModel]);

      verify(
        () =>
            mockPrefs.setString('sports_store_cart_items_user_user_123', any()),
      ).called(1);
    });

    test('clears only user-specific key when clearing cart', () async {
      when(() => mockStorageService.getUserId()).thenReturn('user_123');
      when(() => mockPrefs.remove('sports_store_cart_items_user_user_123'))
          .thenAnswer((_) async => true);

      await dataSource.clearCart();

      verify(() => mockPrefs.remove('sports_store_cart_items_user_user_123'))
          .called(1);
    });
  });
}
