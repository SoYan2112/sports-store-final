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
          selectedSize: '39',
          quantity: 1,
        ),
      ],
      verify: (_) {
        verify(() => mockGetProductDetailUseCase('p1')).called(1);
      },
    );

    blocTest<ProductDetailCubit, ProductDetailState>(
      'emits ProductDetailLoaded with updated selectedSize when selectSize is called',
      build: () => cubit,
      seed: () => const ProductDetailLoaded(
        product: tProduct,
        selectedSize: '39',
      ),
      act: (c) => c.selectSize('41'),
      expect: () => [
        const ProductDetailLoaded(
          product: tProduct,
          selectedSize: '41',
        ),
      ],
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
  });
}
