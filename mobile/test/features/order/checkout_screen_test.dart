import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/address/domain/entities/address_entity.dart';
import 'package:mobile/features/cart/domain/entities/cart_item_entity.dart';
import 'package:mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:mobile/features/cart/presentation/bloc/cart_event.dart';
import 'package:mobile/features/cart/presentation/bloc/cart_state.dart';
import 'package:mobile/features/order/domain/entities/order_entity.dart';
import 'package:mobile/features/order/presentation/bloc/checkout_bloc.dart';
import 'package:mobile/features/order/presentation/bloc/checkout_event.dart';
import 'package:mobile/features/order/presentation/bloc/checkout_state.dart';
import 'package:mobile/features/order/presentation/screens/checkout_screen.dart';
import 'package:mobile/features/order/presentation/screens/ordered-screen.dart';

class MockCheckoutBloc extends MockBloc<CheckoutEvent, CheckoutState>
    implements CheckoutBloc {}

class MockCartBloc extends MockBloc<CartEvent, CartState> implements CartBloc {}

void main() {
  late MockCheckoutBloc mockCheckoutBloc;
  late MockCartBloc mockCartBloc;

  const tAddress = AddressEntity(
    id: 'addr_1',
    recipientName: 'Thái San Yo',
    phoneNumber: '0912345678',
    province: 'TP. Cần Thơ',
    district: 'Quận Ninh Kiều',
    ward: 'Phường An Khánh',
    streetAddress: '600 Nguyễn Văn Cừ',
    label: AddressLabel.home,
    isDefault: true,
  );

  const tCartItem = CartItemEntity(
    id: 'p1_42_4279934490',
    productId: 'p1',
    name: 'Adidas Ultraboost Light',
    brand: 'Adidas',
    price: 1950000,
    imageUrl: 'https://example.com/shoe.png',
    selectedSize: '42',
    selectedColor: 0xFF1A1A1A,
    quantity: 2,
    stock: 10,
  );

  final tOrder = OrderEntity(
    id: 'SS999888',
    userId: 'user_1',
    items: [OrderItemEntity.fromCartItem(tCartItem)],
    shippingAddress: tAddress,
    paymentMethod: PaymentMethod.cod,
    shippingMethod: ShippingMethod.standard,
    subtotal: 3900000,
    shippingFee: 30000,
    totalAmount: 3930000,
    createdAt: DateTime(2026, 10, 27),
  );

  setUpAll(() {
    registerFallbackValue(const PlaceOrderEvent(items: [tCartItem]));
    registerFallbackValue(const ClearCartEvent());
  });

  setUp(() {
    mockCheckoutBloc = MockCheckoutBloc();
    mockCartBloc = MockCartBloc();
    when(() => mockCartBloc.state).thenReturn(
      const CartLoaded(items: [tCartItem]),
    );
  });

  testWidgets(
      'CheckoutScreen renders items, address, payment & shipping methods, and total VND',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    when(() => mockCheckoutBloc.state).thenReturn(
      const CheckoutState(
        status: CheckoutStatus.ready,
        selectedAddress: tAddress,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartBloc>.value(
          value: mockCartBloc,
          child: CheckoutScreen(
            items: const [tCartItem],
            bloc: mockCheckoutBloc,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Xác nhận đặt hàng'), findsOneWidget);
    expect(find.text('Thái San Yo'), findsOneWidget);
    expect(find.text('0912345678'), findsOneWidget);
    expect(find.text('Adidas Ultraboost Light'), findsOneWidget);
    expect(find.text('Size: 42'), findsOneWidget);
    expect(find.text('Thanh toán khi nhận hàng (COD)'), findsOneWidget);
    expect(find.text('3.930.000 ₫'), findsWidgets);
    expect(find.byKey(const Key('placeOrderButton')), findsOneWidget);
  });

  testWidgets(
      'CheckoutScreen places order, clears cart, and navigates to OrderedScreen on success',
      (WidgetTester tester) async {
    const initialState = CheckoutState(
      status: CheckoutStatus.ready,
      selectedAddress: tAddress,
    );
    final successState = CheckoutState(
      status: CheckoutStatus.success,
      selectedAddress: tAddress,
      createdOrder: tOrder,
    );

    when(() => mockCheckoutBloc.state).thenReturn(initialState);
    whenListen(
      mockCheckoutBloc,
      Stream.fromIterable([initialState, successState]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CartBloc>.value(
          value: mockCartBloc,
          child: CheckoutScreen(
            items: const [tCartItem],
            bloc: mockCheckoutBloc,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify CartBloc received ClearCartEvent
    verify(() => mockCartBloc.add(const ClearCartEvent())).called(1);

    // Verify navigated to OrderedScreen (Màn hình Đặt hàng thành công)
    expect(find.byType(OrderedScreen), findsOneWidget);
    expect(find.text('Thanh toán thành công!'), findsOneWidget);
  });
}
