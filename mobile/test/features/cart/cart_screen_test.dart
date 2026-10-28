import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:mobile/features/cart/domain/entities/cart_item_entity.dart';
import 'package:mobile/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:mobile/features/cart/presentation/bloc/cart_event.dart';
import 'package:mobile/features/cart/presentation/bloc/cart_state.dart';
import 'package:mobile/features/cart/presentation/screens/cart_screen.dart';

class MockCartBloc extends MockBloc<CartEvent, CartState> implements CartBloc {}
class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockCartBloc mockCartBloc;
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockCartBloc = MockCartBloc();
    mockAuthCubit = MockAuthCubit();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<CartBloc>.value(
        value: mockCartBloc,
        child: const CartScreen(),
      ),
    );
  }

  const sampleItem = CartItemEntity(
    id: 'p1_42_4279934490',
    productId: 'p1',
    name: 'Nike Joyride Run',
    brand: 'Nike',
    price: 1950000,
    imageUrl: 'https://example.com/shoe.png',
    selectedSize: '42',
    selectedColor: 0xFF1A1A1A,
    quantity: 2,
    stock: 10,
  );

  group('CartScreen Widget Tests', () {
    testWidgets('displays empty cart UI when cart has no items', (tester) async {
      when(() => mockCartBloc.state).thenReturn(const CartLoaded(items: []));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Giỏ hàng của bạn đang trống'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
    });

    testWidgets('displays cart items and checkout summary when cart has items', (tester) async {
      when(() => mockCartBloc.state).thenReturn(
        const CartLoaded(items: [sampleItem]),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Nike Joyride Run'), findsOneWidget);
      expect(find.text('Size: 42'), findsOneWidget);
      expect(find.text('Thanh toán'), findsOneWidget);
      expect(find.text('Tạm tính (2 món):'), findsOneWidget);
      expect(find.text('3.900.000 ₫'), findsOneWidget);
      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('displays unauthenticated UI when user is not logged in', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthUnauthenticated());

      await tester.pumpWidget(MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: mockAuthCubit),
            BlocProvider<CartBloc>.value(value: mockCartBloc),
          ],
          child: const CartScreen(),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Giỏ hàng'), findsOneWidget);
      expect(find.text('Chào mừng đến với Sports Store'), findsOneWidget);
      expect(find.text('Đăng nhập / Đăng ký'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    });
  });
}
