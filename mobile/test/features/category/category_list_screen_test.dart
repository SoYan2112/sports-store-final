import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/category/domain/entities/category_entity.dart';
import 'package:mobile/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:mobile/features/category/presentation/cubit/category_cubit.dart';
import 'package:mobile/features/category/presentation/screens/category_list_screen.dart';
import 'package:mobile/features/category/presentation/widgets/category_card.dart';

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

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: CategoryListScreen(cubit: categoryCubit),
    );
  }

  testWidgets('renders AppBar with title "Danh mục thể thao"',
      (WidgetTester tester) async {
    when(() => mockGetCategoriesUseCase()).thenAnswer((_) async => tCategories);

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Danh mục thể thao'), findsOneWidget);
  });

  testWidgets('renders category items and badges when categories loaded',
      (WidgetTester tester) async {
    when(() => mockGetCategoriesUseCase()).thenAnswer((_) async => tCategories);

    await tester.pumpWidget(createWidgetUnderTest());
    await categoryCubit.fetchCategories();
    await tester.pumpAndSettle();

    expect(find.byType(CategoryCard), findsNWidgets(2));
    expect(find.text('GIÀY THỂ THAO'), findsOneWidget);
    expect(find.text('ÁO THỂ THAO'), findsOneWidget);
    expect(find.text('42 sản phẩm'), findsOneWidget);
    expect(find.text('28 sản phẩm'), findsOneWidget);
  });

  testWidgets('renders error message and retry button on failure',
      (WidgetTester tester) async {
    when(() => mockGetCategoriesUseCase())
        .thenThrow(Exception('Network disconnected'));

    await tester.pumpWidget(createWidgetUnderTest());
    await categoryCubit.fetchCategories();
    await tester.pumpAndSettle();

    expect(
      find.text('Không thể tải danh sách danh mục thể thao. Vui lòng thử lại.'),
      findsOneWidget,
    );
    expect(find.text('Thử lại'), findsOneWidget);
  });
}

