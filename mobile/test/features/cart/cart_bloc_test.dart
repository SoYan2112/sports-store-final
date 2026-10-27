import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/cart/domain/entities/cart_item_entity.dart';
import 'package:mobile/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:mobile/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:mobile/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:mobile/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:mobile/features/cart/domain/usecases/update_cart_quantity_usecase.dart';
import 'package:mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:mobile/features/cart/presentation/bloc/cart_event.dart';
import 'package:mobile/features/cart/presentation/bloc/cart_state.dart';

class MockGetCartUseCase extends Mock implements GetCartUseCase {}
class MockAddToCartUseCase extends Mock implements AddToCartUseCase {}
class MockUpdateCartQuantityUseCase extends Mock implements UpdateCartQuantityUseCase {}
class MockRemoveFromCartUseCase extends Mock implements RemoveFromCartUseCase {}
class MockClearCartUseCase extends Mock implements ClearCartUseCase {}
class FakeCartItemEntity extends Fake implements CartItemEntity {}

void main() {
  late CartBloc cartBloc;
  late MockGetCartUseCase mockGetCartUseCase;
  late MockAddToCartUseCase mockAddToCartUseCase;
  late MockUpdateCartQuantityUseCase mockUpdateCartQuantityUseCase;
  late MockRemoveFromCartUseCase mockRemoveFromCartUseCase;
  late MockClearCartUseCase mockClearCartUseCase;

  setUpAll(() {
    registerFallbackValue(FakeCartItemEntity());
  });

  final testItem = CartItemEntity(
    id: CartItemEntity.generateId('p1', '42', 0xFF1A1A1A),
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
    mockGetCartUseCase = MockGetCartUseCase();
    mockAddToCartUseCase = MockAddToCartUseCase();
    mockUpdateCartQuantityUseCase = MockUpdateCartQuantityUseCase();
    mockRemoveFromCartUseCase = MockRemoveFromCartUseCase();
    mockClearCartUseCase = MockClearCartUseCase();

    cartBloc = CartBloc(
      getCartUseCase: mockGetCartUseCase,
      addToCartUseCase: mockAddToCartUseCase,
      updateCartQuantityUseCase: mockUpdateCartQuantityUseCase,
      removeFromCartUseCase: mockRemoveFromCartUseCase,
      clearCartUseCase: mockClearCartUseCase,
    );
  });

  tearDown(() {
    cartBloc.close();
  });

  group('CartBloc', () {
    test('initial state should be CartInitial', () {
      expect(cartBloc.state, const CartInitial());
    });

    blocTest<CartBloc, CartState>(
      'emits [CartLoading, CartLoaded] when LoadCartEvent succeeds',
      build: () {
        when(() => mockGetCartUseCase()).thenAnswer((_) async => [testItem]);
        return cartBloc;
      },
      act: (bloc) => bloc.add(const LoadCartEvent()),
      expect: () => [
        const CartLoading(),
        CartLoaded(items: [testItem]),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoaded] with updated item when AddToCartEvent is added',
      build: () {
        when(() => mockAddToCartUseCase(
              currentItems: any(named: 'currentItems'),
              newItem: any(named: 'newItem'),
            )).thenAnswer((_) async => [testItem]);
        return cartBloc;
      },
      act: (bloc) => bloc.add(AddToCartEvent(testItem)),
      expect: () => [
        CartLoaded(
          items: [testItem],
          lastAddedItem: testItem,
          notificationMessage: 'Đã thêm ${testItem.name} vào giỏ hàng!',
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoaded] with modified quantity when UpdateCartItemQuantityEvent is added',
      build: () {
        final updatedItem = testItem.copyWith(quantity: 3);
        when(() => mockUpdateCartQuantityUseCase(
              currentItems: any(named: 'currentItems'),
              itemId: any(named: 'itemId'),
              newQuantity: any(named: 'newQuantity'),
            )).thenAnswer((_) async => [updatedItem]);
        return cartBloc;
      },
      act: (bloc) => bloc.add(UpdateCartItemQuantityEvent(
        itemId: testItem.id,
        quantity: 3,
      )),
      expect: () => [
        CartLoaded(items: [testItem.copyWith(quantity: 3)]),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoaded] without item when RemoveCartItemEvent is added',
      build: () {
        when(() => mockRemoveFromCartUseCase(
              currentItems: any(named: 'currentItems'),
              itemId: any(named: 'itemId'),
            )).thenAnswer((_) async => []);
        return cartBloc;
      },
      act: (bloc) => bloc.add(RemoveCartItemEvent(testItem.id)),
      expect: () => [
        const CartLoaded(items: []),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoaded] with empty list when ClearCartEvent is added',
      build: () {
        when(() => mockClearCartUseCase()).thenAnswer((_) async {});
        return cartBloc;
      },
      act: (bloc) => bloc.add(const ClearCartEvent()),
      expect: () => [
        const CartLoaded(items: []),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits [CartLoaded] with empty list when ResetCartEvent is added',
      build: () => cartBloc,
      act: (bloc) => bloc.add(const ResetCartEvent()),
      expect: () => [
        const CartLoaded(items: []),
      ],
    );
  });
}
