import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/product/domain/entities/product_entity.dart';
import 'package:mobile/features/product/domain/usecases/get_products_usecase.dart';
import 'package:mobile/features/product/presentation/bloc/product_bloc.dart';
import 'package:mobile/features/product/presentation/bloc/product_state.dart';
import 'package:mobile/features/product/presentation/screens/product_list_screen.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

void main() {
  late MockGetProductsUseCase mockGetProductsUseCase;
  late ProductBloc productBloc;

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
    category: 'Giày thể thao',
    stock: 10,
  );

  setUp(() {
    mockGetProductsUseCase = MockGetProductsUseCase();
    when(() => mockGetProductsUseCase(
          page: any(named: 'page'),
          size: any(named: 'size'),
          categoryId: any(named: 'categoryId'),
          keyword: any(named: 'keyword'),
        )).thenAnswer((_) async => [tProduct]);

    productBloc = ProductBloc(getProductsUseCase: mockGetProductsUseCase);
  });

  tearDown(() {
    productBloc.close();
  });

  testWidgets('ProductListScreen renders category title and products without overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProductBloc>.value(
          value: productBloc,
          child: const ProductListScreen(
            categoryId: 'cat_shoes',
            categoryName: 'Giày thể thao',
          ),
        ),
      ),
    );

    // Initial loading
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Giày thể thao'), findsOneWidget);
    expect(find.byType(ProductListScreen), findsOneWidget);

    productBloc.emit(ProductLoaded(
      products: const [tProduct],
      hasReachedMax: true,
      currentPage: 1,
    ));
    await tester.pump();
    expect(find.text('Giày thể thao'), findsOneWidget);
    expect(find.text('Sản phẩm phổ biến'), findsOneWidget);
    expect(find.byType(ProductListScreen), findsOneWidget);
  });
}

