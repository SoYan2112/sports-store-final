import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/product/domain/entities/product_entity.dart';
import 'package:mobile/features/product/domain/usecases/get_products_usecase.dart';
import 'package:mobile/features/product/presentation/cubit/search_cubit.dart';
import 'package:mobile/features/product/presentation/screens/search_screen.dart';

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

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<SearchCubit>.value(
        value: searchCubit,
        child: const SearchScreen(),
      ),
    );
  }

  testWidgets('SearchScreen renders initial placeholder and search field',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());

    expect(find.byType(TextField), findsOneWidget);
    expect(
      find.text('Nhập từ khóa để tìm kiếm sản phẩm thể thao'),
      findsOneWidget,
    );
  });

  testWidgets('SearchScreen renders products when search finds results',
      (WidgetTester tester) async {
    when(() => mockGetProductsUseCase(
          page: any(named: 'page'),
          size: any(named: 'size'),
          keyword: 'Nike',
        )).thenAnswer((_) async => [tProduct]);

    await tester.pumpWidget(buildTestWidget());

    await tester.enterText(find.byType(TextField), 'Nike');
    await tester.pump();

    expect(find.text('Nike unveil joyride'), findsOneWidget);
    expect(find.text('NIKE'), findsOneWidget);
    expect(find.text('1.950.000 ₫'), findsOneWidget);
  });
}
