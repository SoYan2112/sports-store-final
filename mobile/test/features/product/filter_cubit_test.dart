import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/product/presentation/cubit/filter_cubit.dart';
import 'package:mobile/features/product/presentation/cubit/filter_state.dart';

void main() {
  late FilterCubit filterCubit;

  setUp(() {
    filterCubit = FilterCubit();
  });

  tearDown(() {
    filterCubit.close();
  });

  group('FilterCubit', () {
    test('initial state should have default filter values', () {
      expect(filterCubit.state, const FilterState());
      expect(filterCubit.state.selectedBrand, 'Tất cả');
      expect(filterCubit.state.minPrice, 0);
      expect(filterCubit.state.maxPrice, 5000000);
      expect(filterCubit.state.isDefault, isTrue);
    });

    blocTest<FilterCubit, FilterState>(
      'emits updated FilterState when updateFilter is called',
      build: () => filterCubit,
      act: (cubit) => cubit.updateFilter(
        brand: 'Nike',
        minPrice: 500000,
        maxPrice: 2000000,
      ),
      expect: () => [
        const FilterState(
          selectedBrand: 'Nike',
          minPrice: 500000,
          maxPrice: 2000000,
        ),
      ],
      verify: (cubit) {
        expect(cubit.state.isDefault, isFalse);
      },
    );

    blocTest<FilterCubit, FilterState>(
      'emits default FilterState when reset is called',
      build: () => filterCubit,
      seed: () => const FilterState(
        selectedBrand: 'Adidas',
        minPrice: 1000000,
        maxPrice: 3000000,
      ),
      act: (cubit) => cubit.reset(),
      expect: () => [
        const FilterState(),
      ],
      verify: (cubit) {
        expect(cubit.state.isDefault, isTrue);
      },
    );
  });
}
