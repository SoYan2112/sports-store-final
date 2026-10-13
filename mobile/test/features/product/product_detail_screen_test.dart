import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/product/domain/entities/product_entity.dart';
import 'package:mobile/features/product/domain/usecases/get_product_detail_usecase.dart';
import 'package:mobile/features/product/presentation/cubit/product_detail_cubit.dart';
import 'package:mobile/features/product/presentation/cubit/product_detail_state.dart';
import 'package:mobile/features/product/presentation/screens/product_detail_screen.dart';

class MockGetProductDetailUseCase extends Mock
    implements GetProductDetailUseCase {}

void main() {
  late MockGetProductDetailUseCase mockGetProductDetailUseCase;

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
    colors: [0xFF1A1A1A, 0xFFFFFFFF],
  );

  setUp(() {
    mockGetProductDetailUseCase = MockGetProductDetailUseCase();
    when(() => mockGetProductDetailUseCase(any()))
        .thenAnswer((_) async => tProduct);
  });

  testWidgets('ProductDetailScreen renders product info, sizes, and CTA button',
      (WidgetTester tester) async {
    final cubit = ProductDetailCubit(
      getProductDetailUseCase: mockGetProductDetailUseCase,
    );
    cubit.emit(const ProductDetailLoaded(
      product: tProduct,
      selectedSize: '39',
      quantity: 1,
    ));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ProductDetailCubit>.value(
          value: cubit,
          child: const ProductDetailScreen(
            product: tProduct,
          ),
        ),
      ),
    );

    await tester.pump();

    // Kiểm tra tên sản phẩm và thương hiệu
    expect(find.text('Nike unveil joyride'), findsOneWidget);
    expect(find.text('NIKE'), findsOneWidget);

    // Kiểm tra giá tiền định dạng VNĐ
    expect(find.text('1.950.000 ₫'), findsWidgets);

    // Kiểm tra size chips
    expect(find.text('39'), findsOneWidget);
    expect(find.text('40'), findsOneWidget);
    expect(find.text('41'), findsOneWidget);

    // Kiểm tra nút Thêm vào giỏ hàng
    expect(find.text('Thêm vào giỏ hàng'), findsOneWidget);

    // Kiểm tra số lượng tồn kho
    expect(find.text('Còn 10 sản phẩm'), findsOneWidget);

    await cubit.close();
  });
}
