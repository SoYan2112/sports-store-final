import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/product/domain/entities/product_entity.dart';
import 'package:mobile/features/product/domain/usecases/get_product_detail_usecase.dart';
import 'package:mobile/features/product/presentation/cubit/product_detail_cubit.dart';
import 'package:mobile/features/product/presentation/cubit/product_detail_state.dart';

class MockGetProductDetailUseCase extends Mock
    implements GetProductDetailUseCase {}

void main() {
  late MockGetProductDetailUseCase mockGetProductDetailUseCase;
  late ProductDetailCubit cubit;

  const tProduct = ProductEntity(
    id: 'p1',
    name: 'Nike unveil joyride',
    brand: 'Nike',
    price: 1950000,
    originalPrice: 2450000,
    imageUrl: 'https://example.com/shoe.png',
    badge: 'Hot',
    rating: 4.9,
    reviewCount: 128,
    description: 'Giày chạy bộ cao cấp',
    stock: 10,
    sizes: ['39', '40', '41'],
  );

  setUp(() {
    mockGetProductDetailUseCase = MockGetProductDetailUseCase();
    cubit = ProductDetailCubit(
      getProductDetailUseCase: mockGetProductDetailUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('ProductDetailCubit', () {
    test('initial state should be ProductDetailInitial', () {
      expect(cubit.state, const ProductDetailInitial());
    });

    blocTest<ProductDetailCubit, ProductDetailState>(
      'emits [ProductDetailLoading, ProductDetailLoaded] when loadProduct succeeds',
      build: () {
        when(() => mockGetProductDetailUseCase('p1'))
            .thenAnswer((_) async => tProduct);
        return cubit;
      },
      act: (c) => c.loadProduct('p1'),
      expect: () => [
        const ProductDetailLoading(),
        const ProductDetailLoaded(
          product: tProduct,
          quantity: 1,
        ),
      ],
      verify: (_) {
        verify(() => mockGetProductDetailUseCase('p1')).called(1);
      },
    );

    blocTest<ProductDetailCubit, ProductDetailState>(
      'increments and decrements quantity correctly within bounds',
      build: () => cubit,
      seed: () => const ProductDetailLoaded(
        product: tProduct,
        quantity: 1,
      ),
      act: (c) {
        c.incrementQuantity();
        c.incrementQuantity();
        c.decrementQuantity();
      },
      expect: () => [
        const ProductDetailLoaded(product: tProduct, quantity: 2),
        const ProductDetailLoaded(product: tProduct, quantity: 3),
        const ProductDetailLoaded(product: tProduct, quantity: 2),
      ],
    );

    blocTest<ProductDetailCubit, ProductDetailState>(
      'selectColor updates selectedColor in state',
      build: () => cubit,
      seed: () => const ProductDetailLoaded(
        product: tProduct,
        quantity: 1,
      ),
      act: (c) => c.selectColor(0xFF1A1A1A),
      expect: () => [
        const ProductDetailLoaded(
          product: tProduct,
          quantity: 1,
          selectedColor: 0xFF1A1A1A,
        ),
      ],
    );

    blocTest<ProductDetailCubit, ProductDetailState>(
      'selectSize updates selectedSize when size is in stock',
      build: () => cubit,
      seed: () => const ProductDetailLoaded(
        product: tProduct,
        quantity: 1,
        outOfStockSizes: ['43'],
      ),
      act: (c) => c.selectSize('40'),
      expect: () => [
        const ProductDetailLoaded(
          product: tProduct,
          quantity: 1,
          selectedSize: '40',
          outOfStockSizes: ['43'],
        ),
      ],
    );

    blocTest<ProductDetailCubit, ProductDetailState>(
      'selectSize does not update when size is out of stock',
      build: () => cubit,
      seed: () => const ProductDetailLoaded(
        product: tProduct,
        quantity: 1,
        outOfStockSizes: ['43'],
      ),
      act: (c) => c.selectSize('43'),
      expect: () => [],
    );

    test('canAddToCart returns true only when both size and color are selected and in stock', () {
      const stateWithoutSelection = ProductDetailLoaded(
        product: tProduct,
        quantity: 1,
      );
      expect(stateWithoutSelection.canAddToCart, isFalse);

      const stateWithSizeOnly = ProductDetailLoaded(
        product: tProduct,
        quantity: 1,
        selectedSize: '40',
      );
      expect(stateWithSizeOnly.canAddToCart, isFalse);

      const stateWithColorOnly = ProductDetailLoaded(
        product: tProduct,
        quantity: 1,
        selectedColor: 0xFF1A1A1A,
      );
      expect(stateWithColorOnly.canAddToCart, isFalse);

      const stateWithBoth = ProductDetailLoaded(
        product: tProduct,
        quantity: 1,
        selectedSize: '40',
        selectedColor: 0xFF1A1A1A,
        outOfStockSizes: ['43'],
      );
      expect(stateWithBoth.canAddToCart, isTrue);

      const stateWithOutOfStockSize = ProductDetailLoaded(
        product: tProduct,
        quantity: 1,
        selectedSize: '43',
        selectedColor: 0xFF1A1A1A,
        outOfStockSizes: ['43'],
      );
      expect(stateWithOutOfStockSize.canAddToCart, isFalse);
    });
  });
}
