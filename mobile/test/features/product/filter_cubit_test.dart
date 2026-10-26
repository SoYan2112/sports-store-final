import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/product/domain/entities/product_entity.dart';
import 'package:mobile/features/product/presentation/cubit/filter_cubit.dart';
import 'package:mobile/features/product/presentation/cubit/filter_state.dart';

void main() {
  late FilterCubit cubit;

  const tProductNike = ProductEntity(
    id: 'p1',
    name: 'Nike Air Max',
    brand: 'Nike',
    price: 2000000,
    imageUrl: 'https://example.com/shoe.png',
    category: 'Giày thể thao',
  );

  const tProductAdidas = ProductEntity(
    id: 'p2',
    name: 'Adidas Track Top',
    brand: 'Adidas',
    price: 1500000,
    imageUrl: 'https://example.com/top.png',
    category: 'Áo thể thao',
  );

  const tProductPuma = ProductEntity(
    id: 'p3',
    name: 'Puma Shorts',
    brand: 'Puma',
    price: 600000,
    imageUrl: 'https://example.com/shorts.png',
    category: 'Quần thể thao',
  );

  setUp(() {
    cubit = FilterCubit();
  });

  tearDown(() {
    cubit.close();
  });

  group('FilterCubit & FilterState', () {
    test('initial state should be default values', () {
      expect(cubit.state, const FilterState());
      expect(cubit.state.isDefault, isTrue);
      expect(cubit.state.activeFilterCount, 0);
      expect(cubit.state.minPrice, 0);
      expect(cubit.state.maxPrice, 5000000);
      expect(cubit.state.selectedBrands, isEmpty);
      expect(cubit.state.selectedCategories, isEmpty);
    });

    test('updateFilter emits correct state and updates activeFilterCount', () {
      cubit.updateFilter(
        brands: ['Nike', 'Adidas'],
        categories: ['Giày thể thao'],
        minPrice: 1000000,
        maxPrice: 3000000,
      );

      final state = cubit.state;
      expect(state.selectedBrands, ['Nike', 'Adidas']);
      expect(state.selectedCategories, ['Giày thể thao']);
      expect(state.minPrice, 1000000);
      expect(state.maxPrice, 3000000);
      expect(state.isDefault, isFalse);
      expect(state.activeFilterCount, 4); // 2 brands + 1 category + 1 price range
    });

    test('toggleBrand adds and removes brand correctly', () {
      cubit.toggleBrand('Nike');
      expect(cubit.state.selectedBrands, ['Nike']);
      expect(cubit.state.isDefault, isFalse);

      cubit.toggleBrand('Nike');
      expect(cubit.state.selectedBrands, isEmpty);
      expect(cubit.state.isDefault, isTrue);
    });

    test('toggleCategory adds and removes category correctly', () {
      cubit.toggleCategory('Áo thể thao');
      expect(cubit.state.selectedCategories, ['Áo thể thao']);
      expect(cubit.state.isDefault, isFalse);

      cubit.toggleCategory('Áo thể thao');
      expect(cubit.state.selectedCategories, isEmpty);
      expect(cubit.state.isDefault, isTrue);
    });

    test('setPriceRange updates min and max price', () {
      cubit.setPriceRange(500000, 2000000);
      expect(cubit.state.minPrice, 500000);
      expect(cubit.state.maxPrice, 2000000);
      expect(cubit.state.activeFilterCount, 1);
    });

    test('reset restores initial default state', () {
      cubit.updateFilter(
        brands: ['Nike'],
        categories: ['Giày thể thao'],
        minPrice: 500000,
        maxPrice: 2000000,
      );
      expect(cubit.state.isDefault, isFalse);

      cubit.reset();
      expect(cubit.state.isDefault, isTrue);
      expect(cubit.state.selectedBrands, isEmpty);
      expect(cubit.state.selectedCategories, isEmpty);
      expect(cubit.state.minPrice, 0);
      expect(cubit.state.maxPrice, 5000000);
    });

    group('FilterState.matches() logic', () {
      test('matches all products when state is default', () {
        const state = FilterState();
        expect(state.matches(tProductNike), isTrue);
        expect(state.matches(tProductAdidas), isTrue);
        expect(state.matches(tProductPuma), isTrue);
      });

      test('filters correctly by brand', () {
        const state = FilterState(selectedBrands: ['Nike']);
        expect(state.matches(tProductNike), isTrue);
        expect(state.matches(tProductAdidas), isFalse);
        expect(state.matches(tProductPuma), isFalse);
      });

      test('filters correctly by category', () {
        const state = FilterState(selectedCategories: ['Áo thể thao']);
        expect(state.matches(tProductNike), isFalse);
        expect(state.matches(tProductAdidas), isTrue);
        expect(state.matches(tProductPuma), isFalse);
      });

      test('filters correctly by price range', () {
        const state = FilterState(minPrice: 1000000, maxPrice: 1800000);
        expect(state.matches(tProductNike), isFalse); // 2.000.000 > max
        expect(state.matches(tProductAdidas), isTrue); // 1.500.000 in range
        expect(state.matches(tProductPuma), isFalse); // 600.000 < min
      });

      test('filters correctly with combined criteria', () {
        const state = FilterState(
          selectedBrands: ['Nike', 'Adidas'],
          selectedCategories: ['Giày thể thao'],
          minPrice: 1500000,
          maxPrice: 3000000,
        );
        expect(state.matches(tProductNike), isTrue); // Nike, Giày, 2tr
        expect(state.matches(tProductAdidas), isFalse); // Áo, not Giày
        expect(state.matches(tProductPuma), isFalse); // Puma, not in brand list
      });
    });
  });
}
