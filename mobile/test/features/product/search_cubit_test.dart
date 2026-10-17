import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/product/domain/entities/product_entity.dart';
import 'package:mobile/features/product/domain/usecases/get_products_usecase.dart';
import 'package:mobile/features/product/presentation/cubit/search_cubit.dart';
import 'package:mobile/features/product/presentation/cubit/search_state.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

void main() {
  late MockGetProductsUseCase mockGetProductsUseCase;
  late SearchCubit searchCubit;

  const tProduct = ProductEntity(
    id: 'p1',
    name: 'Nike unveil joyride',
    brand: 'Nike',
    price: 1950000,
    imageUrl: 'https://example.com/shoe.png',
    badge: 'Hot',
    rating: 4.9,
    reviewCount: 128,
    description: 'Giày chạy bộ',
    stock: 10,
  );

  setUp(() {
    mockGetProductsUseCase = MockGetProductsUseCase();
    searchCubit = SearchCubit(getProductsUseCase: mockGetProductsUseCase);
  });

  tearDown(() {
    searchCubit.close();
  });

  group('SearchCubit', () {
    test('initial state should be SearchInitial', () {
      expect(searchCubit.state, const SearchInitial());
    });

    blocTest<SearchCubit, SearchState>(
      'emits [SearchInitial] when query is empty',
      build: () => searchCubit,
      act: (cubit) => cubit.search('   '),
      expect: () => [const SearchInitial()],
    );

    blocTest<SearchCubit, SearchState>(
      'emits [SearchLoading, SearchLoaded] when search finds products',
      build: () {
        when(() => mockGetProductsUseCase(
              page: any(named: 'page'),
              size: any(named: 'size'),
              keyword: 'Nike',
            )).thenAnswer((_) async => [tProduct]);
        return searchCubit;
      },
      act: (cubit) => cubit.search('Nike'),
      expect: () => [
        const SearchLoading(),
        const SearchLoaded([tProduct]),
      ],
      verify: (_) {
        verify(() => mockGetProductsUseCase(
              page: 1,
              size: 50,
              keyword: 'Nike',
            )).called(1);
      },
    );

    blocTest<SearchCubit, SearchState>(
      'emits [SearchLoading, SearchEmpty] when search finds no products',
      build: () {
        when(() => mockGetProductsUseCase(
              page: any(named: 'page'),
              size: any(named: 'size'),
              keyword: 'Unknown',
            )).thenAnswer((_) async => []);
        return searchCubit;
      },
      act: (cubit) => cubit.search('Unknown'),
      expect: () => [
        const SearchLoading(),
        const SearchEmpty('Unknown'),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'emits [SearchInitial] when clear() is called',
      build: () => searchCubit,
      seed: () => const SearchLoaded([tProduct]),
      act: (cubit) => cubit.clear(),
      expect: () => [const SearchInitial()],
    );
  });
}
