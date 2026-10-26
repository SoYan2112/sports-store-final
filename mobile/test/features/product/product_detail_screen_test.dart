import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:mobile/features/cart/presentation/bloc/cart_event.dart';
import 'package:mobile/features/cart/presentation/bloc/cart_state.dart';
import 'package:mobile/features/product/domain/entities/product_entity.dart';
import 'package:mobile/features/product/domain/usecases/get_product_detail_usecase.dart';
import 'package:mobile/features/product/presentation/cubit/product_detail_cubit.dart';
import 'package:mobile/features/product/presentation/cubit/product_detail_state.dart';
import 'package:mobile/features/product/presentation/screens/product_detail_screen.dart';

class MockGetProductDetailUseCase extends Mock
    implements GetProductDetailUseCase {}

class MockCartBloc extends MockBloc<CartEvent, CartState> implements CartBloc {}

class FakeCartEvent extends Fake implements CartEvent {}

void main() {
  late MockGetProductDetailUseCase mockGetProductDetailUseCase;
  late MockCartBloc mockCartBloc;

  setUpAll(() {
    registerFallbackValue(FakeCartEvent());
  });

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
    mockCartBloc = MockCartBloc();
    when(() => mockGetProductDetailUseCase(any()))
        .thenAnswer((_) async => tProduct);
    when(() => mockCartBloc.state).thenReturn(const CartLoaded(items: []));
  });

  tearDown(() {
    mockCartBloc.close();
  });

  Widget createWidgetUnderTest(ProductDetailCubit cubit) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ProductDetailCubit>.value(value: cubit),
          BlocProvider<CartBloc>.value(value: mockCartBloc),
        ],
        child: const ProductDetailScreen(product: tProduct),
      ),
    );
  }

  testWidgets('ProductDetailScreen renders product info and CTA button',
      (WidgetTester tester) async {
    final cubit = ProductDetailCubit(
      getProductDetailUseCase: mockGetProductDetailUseCase,
    );
    cubit.emit(const ProductDetailLoaded(
      product: tProduct,
      quantity: 1,
    ));

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pump();

    // Kiểm tra tên sản phẩm và thương hiệu
    expect(find.text('Nike unveil joyride'), findsOneWidget);
    expect(find.text('NIKE'), findsOneWidget);

    // Kiểm tra giá tiền định dạng VNĐ
    expect(find.text('1.950.000 ₫'), findsWidgets);

    // Kiểm tra nút Thêm vào giỏ hàng
    expect(find.text('Thêm vào giỏ hàng'), findsOneWidget);

    // Kiểm tra số lượng tồn kho
    expect(find.text('Còn 10 sản phẩm'), findsOneWidget);

    // Nút Thêm vào giỏ hàng bị disabled khi chưa chọn size & màu
    final button = tester.widget<ElevatedButton>(find.byKey(const Key('addToCartButton')));
    expect(button.onPressed, isNull);

    // Kiểm tra hiển thị size chips
    expect(find.text('39'), findsOneWidget);
    expect(find.text('40'), findsOneWidget);
    expect(find.text('41'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('ProductDetailScreen enables CTA button when size and color are selected',
      (WidgetTester tester) async {
    final cubit = ProductDetailCubit(
      getProductDetailUseCase: mockGetProductDetailUseCase,
    );
    cubit.emit(const ProductDetailLoaded(
      product: tProduct,
      quantity: 1,
      selectedSize: '40',
      selectedColor: 0xFF1A1A1A,
    ));

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await tester.pump();

    // Nút Thêm vào giỏ hàng được enabled khi đã chọn đủ size & màu
    final button = tester.widget<ElevatedButton>(find.byKey(const Key('addToCartButton')));
    expect(button.onPressed, isNotNull);

    // Kiểm tra text đã chọn
    expect(find.text('Đã chọn: 40'), findsOneWidget);

    // Tapping add to cart triggers CartBloc event
    await tester.tap(find.byKey(const Key('addToCartButton')));
    await tester.pump();

    verify(() => mockCartBloc.add(any(that: isA<AddToCartEvent>()))).called(1);

    await cubit.close();
  });
}
