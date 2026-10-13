import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/product/domain/entities/product_entity.dart';
import 'package:mobile/features/product/domain/usecases/get_products_usecase.dart';
import 'package:mobile/features/product/presentation/bloc/product_bloc.dart';
import 'package:mobile/features/product/presentation/bloc/product_event.dart';
import 'package:mobile/features/product/presentation/bloc/product_state.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

void main() {
  late MockGetProductsUseCase mockGetProductsUseCase;
  late ProductBloc productBloc;

  setUp(() {
    mockGetProductsUseCase = MockGetProductsUseCase();
    productBloc = ProductBloc(getProductsUseCase: mockGetProductsUseCase);
  });

  tearDown(() {
    productBloc.close();
  });

  const testProducts = [
    ProductEntity(
      id: 'p1',
      name: 'Nike unveil joyride',
      brand: 'Nike',
      price: 1950000,
      imageUrl: 'https://example.com/shoe.png',
      badge: 'Hot',
    ),
  ];

  group('ProductBloc - FetchProductsEvent', () {
    test('initial state should be ProductInitial', () {
      expect(productBloc.state, const ProductInitial());
    });

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductLoaded] when fetch succeeds',
      build: () {
        when(() => mockGetProductsUseCase(
              page: 1,
              size: any(named: 'size'),
              categoryId: any(named: 'categoryId'),
              keyword: any(named: 'keyword'),
            )).thenAnswer((_) async => testProducts);
        return productBloc;
      },
      act: (bloc) => bloc.add(const FetchProductsEvent()),
      expect: () => [
        const ProductLoading(),
        const ProductLoaded(
          products: testProducts,
          hasReachedMax: true,
          currentPage: 1,
        ),
      ],
      verify: (_) {
        verify(() => mockGetProductsUseCase(
              page: 1,
              size: 6,
            )).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when fetch fails',
      build: () {
        when(() => mockGetProductsUseCase(
              page: 1,
              size: any(named: 'size'),
              categoryId: any(named: 'categoryId'),
              keyword: any(named: 'keyword'),
            )).thenThrow(Exception('Network Error'));
        return productBloc;
      },
      act: (bloc) => bloc.add(const FetchProductsEvent()),
      expect: () => [
        const ProductLoading(),
        const ProductError(
          message: 'Không thể tải danh sách sản phẩm. Vui lòng thử lại sau.',
        ),
      ],
    );
  });
}
