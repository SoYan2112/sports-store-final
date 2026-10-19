import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/category/domain/entities/category_entity.dart';
import 'package:mobile/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:mobile/features/category/presentation/cubit/category_cubit.dart';
import 'package:mobile/features/category/presentation/cubit/category_state.dart';

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

void main() {
  late MockGetCategoriesUseCase mockGetCategoriesUseCase;
  late CategoryCubit categoryCubit;

  const tCategories = [
    CategoryEntity(
      id: 'cat_shoes',
      name: 'Giày thể thao',
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
      itemCount: 42,
    ),
    CategoryEntity(
      id: 'cat_apparel',
      name: 'Áo thể thao',
      imageUrl: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518',
      itemCount: 28,
    ),
  ];

  setUp(() {
    mockGetCategoriesUseCase = MockGetCategoriesUseCase();
    categoryCubit = CategoryCubit(getCategoriesUseCase: mockGetCategoriesUseCase);
  });

  tearDown(() {
    categoryCubit.close();
  });

  group('CategoryCubit', () {
    test('initial state should be CategoryInitial', () {
      expect(categoryCubit.state, const CategoryInitial());
    });

    blocTest<CategoryCubit, CategoryState>(
      'emits [CategoryLoading, CategoryLoaded] when fetchCategories succeeds',
      build: () {
        when(() => mockGetCategoriesUseCase())
            .thenAnswer((_) async => tCategories);
        return categoryCubit;
      },
      act: (cubit) => cubit.fetchCategories(),
      expect: () => [
        const CategoryLoading(),
        const CategoryLoaded(categories: tCategories),
      ],
      verify: (_) {
        verify(() => mockGetCategoriesUseCase()).called(1);
      },
    );

    blocTest<CategoryCubit, CategoryState>(
      'emits [CategoryLoading, CategoryError] when fetchCategories fails',
      build: () {
        when(() => mockGetCategoriesUseCase())
            .thenThrow(Exception('Server error'));
        return categoryCubit;
      },
      act: (cubit) => cubit.fetchCategories(),
      expect: () => [
        const CategoryLoading(),
        const CategoryError(
          message: 'Không thể tải danh sách danh mục thể thao. Vui lòng thử lại.',
        ),
      ],
      verify: (_) {
        verify(() => mockGetCategoriesUseCase()).called(1);
      },
    );
  });
}

