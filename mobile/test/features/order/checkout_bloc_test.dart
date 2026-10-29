import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/storage/local_storage_service.dart';
import 'package:mobile/features/address/domain/entities/address_entity.dart';
import 'package:mobile/features/address/domain/usecases/get_addresses_usecase.dart';
import 'package:mobile/features/cart/domain/entities/cart_item_entity.dart';
import 'package:mobile/features/order/data/datasources/order_remote_datasource.dart';
import 'package:mobile/features/order/data/models/order_model.dart';
import 'package:mobile/features/order/domain/entities/order_entity.dart';
import 'package:mobile/features/order/domain/usecases/create_order_usecase.dart';
import 'package:mobile/features/order/presentation/bloc/checkout_bloc.dart';
import 'package:mobile/features/order/presentation/bloc/checkout_event.dart';
import 'package:mobile/features/order/presentation/bloc/checkout_state.dart';
import 'package:mobile/features/voucher/domain/entities/voucher_entity.dart';

class MockCreateOrderUseCase extends Mock implements CreateOrderUseCase {}

class MockGetAddressesUseCase extends Mock implements GetAddressesUseCase {}

void main() {
  late MockCreateOrderUseCase mockCreateOrderUseCase;
  late MockGetAddressesUseCase mockGetAddressesUseCase;
  late CheckoutBloc checkoutBloc;

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
    id: 'SS123456',
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
    registerFallbackValue(
      CreateOrderParams(
        items: [OrderItemEntity.fromCartItem(tCartItem)],
        shippingAddress: tAddress,
        paymentMethod: PaymentMethod.cod,
        shippingMethod: ShippingMethod.standard,
        subtotal: 3900000,
        shippingFee: 30000,
      ),
    );
  });

  setUp(() {
    mockCreateOrderUseCase = MockCreateOrderUseCase();
    mockGetAddressesUseCase = MockGetAddressesUseCase();
    checkoutBloc = CheckoutBloc(
      createOrderUseCase: mockCreateOrderUseCase,
      getAddressesUseCase: mockGetAddressesUseCase,
    );
  });

  tearDown(() {
    checkoutBloc.close();
  });

  group('OrderModel & OrderRemoteDataSourceImpl', () {
    test('OrderModel toJson and fromJson round-trip preserves all fields', () {
      final model = OrderModel.fromEntity(tOrder);
      final json = model.toJson();
      final decoded = OrderModel.fromJson(json);

      expect(decoded.id, tOrder.id);
      expect(decoded.userId, tOrder.userId);
      expect(decoded.subtotal, 3900000);
      expect(decoded.shippingFee, 30000);
      expect(decoded.totalAmount, 3930000);
      expect(decoded.paymentMethod, PaymentMethod.cod);
      expect(decoded.shippingMethod, ShippingMethod.standard);
      expect(decoded.items.length, 1);
      expect(decoded.items.first.name, 'Adidas Ultraboost Light');
    });

    test('OrderRemoteDataSourceImpl saves and retrieves user-scoped orders locally', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      await storageService.saveAuthSession(
        token: 'token_u1',
        userId: 'user_1',
        name: 'YoTS',
        email: 'yots@example.com',
      );

      final dataSource = OrderRemoteDataSourceImpl(
        sharedPreferences: prefs,
        storageService: storageService,
      );

      final created = await dataSource.createOrder(
        OrderModel.fromEntity(tOrder).toJson(),
      );

      expect(created.userId, 'user_1');
      final orders = await dataSource.getOrders();
      expect(orders.length, 1);
    });
  });

  group('CheckoutBloc', () {
    test('initial state has CheckoutStatus.initial and COD payment method', () {
      expect(checkoutBloc.state.status, CheckoutStatus.initial);
      expect(checkoutBloc.state.paymentMethod, PaymentMethod.cod);
      expect(checkoutBloc.state.shippingMethod, ShippingMethod.standard);
    });

    blocTest<CheckoutBloc, CheckoutState>(
      'emits [loadingAddress, ready] with default address when LoadCheckoutDataEvent succeeds',
      build: () {
        when(() => mockGetAddressesUseCase()).thenAnswer(
          (_) async => [tAddress],
        );
        return checkoutBloc;
      },
      act: (bloc) => bloc.add(const LoadCheckoutDataEvent()),
      expect: () => [
        const CheckoutState(status: CheckoutStatus.loadingAddress),
        const CheckoutState(
          status: CheckoutStatus.ready,
          selectedAddress: tAddress,
        ),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'updates paymentMethod and shippingMethod when selection events are added',
      build: () => checkoutBloc,
      act: (bloc) {
        bloc.add(const SelectPaymentMethodEvent(PaymentMethod.vnpay));
        bloc.add(const SelectShippingMethodEvent(ShippingMethod.express));
      },
      expect: () => [
        const CheckoutState(
          status: CheckoutStatus.ready,
          paymentMethod: PaymentMethod.vnpay,
        ),
        const CheckoutState(
          status: CheckoutStatus.ready,
          paymentMethod: PaymentMethod.vnpay,
          shippingMethod: ShippingMethod.express,
        ),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'emits failure when PlaceOrderEvent is added without a selected shipping address',
      build: () => checkoutBloc,
      act: (bloc) => bloc.add(
        const PlaceOrderEvent(items: [tCartItem]),
      ),
      expect: () => [
        const CheckoutState(
          status: CheckoutStatus.failure,
          errorMessage: 'Vui lòng chọn địa chỉ nhận hàng trước khi đặt hàng.',
        ),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'emits [submitting, success] when PlaceOrderEvent succeeds with selected address',
      build: () {
        when(() => mockCreateOrderUseCase(any())).thenAnswer(
          (_) async => tOrder,
        );
        return checkoutBloc;
      },
      seed: () => const CheckoutState(
        status: CheckoutStatus.ready,
        selectedAddress: tAddress,
      ),
      act: (bloc) => bloc.add(
        const PlaceOrderEvent(
          items: [tCartItem],
          note: 'Giao giờ hành chính',
        ),
      ),
      expect: () => [
        const CheckoutState(
          status: CheckoutStatus.submitting,
          selectedAddress: tAddress,
        ),
        CheckoutState(
          status: CheckoutStatus.success,
          selectedAddress: tAddress,
          createdOrder: tOrder,
        ),
      ],
    );

    final tVoucherPercentage = VoucherEntity(
      id: 'v_summer20',
      code: 'SUMMER20',
      title: 'Giảm 20% đơn từ 400k',
      description: 'Áp dụng cho đồ thể thao',
      type: VoucherType.percentage,
      discountValue: 20,
      minOrderValue: 400000,
      maxDiscountAmount: 100000,
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 10)),
    );

    final tVoucherExpired = VoucherEntity(
      id: 'v_expired',
      code: 'EXPIRED10',
      title: 'Mã đã hết hạn',
      description: 'Hết hạn',
      type: VoucherType.fixedAmount,
      discountValue: 50000,
      minOrderValue: 200000,
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      endDate: DateTime.now().subtract(const Duration(days: 1)),
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'emits state with appliedVoucher and discountAmount when ApplyVoucherEvent succeeds',
      build: () => checkoutBloc,
      act: (bloc) => bloc.add(ApplyVoucherEvent(
        voucher: tVoucherPercentage,
        subtotal: 500000,
      )),
      expect: () => [
        isA<CheckoutState>()
            .having((s) => s.appliedVoucher?.code, 'code', 'SUMMER20')
            .having((s) => s.discountAmount, 'discountAmount', 100000),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'emits failure state when applied voucher is expired',
      build: () => checkoutBloc,
      act: (bloc) => bloc.add(ApplyVoucherEvent(
        voucher: tVoucherExpired,
        subtotal: 500000,
      )),
      expect: () => [
        isA<CheckoutState>()
            .having((s) => s.status, 'status', CheckoutStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage',
                contains('hết hạn sử dụng')),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'emits failure state when subtotal is below minOrderValue',
      build: () => checkoutBloc,
      act: (bloc) => bloc.add(ApplyVoucherEvent(
        voucher: tVoucherPercentage,
        subtotal: 300000,
      )),
      expect: () => [
        isA<CheckoutState>()
            .having((s) => s.status, 'status', CheckoutStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage',
                contains('chưa đạt giá trị tối thiểu')),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'removes applied voucher and resets discountAmount when RemoveVoucherEvent called',
      build: () => checkoutBloc,
      seed: () => CheckoutState(
        appliedVoucher: tVoucherPercentage,
        discountAmount: 100000,
      ),
      act: (bloc) => bloc.add(const RemoveVoucherEvent()),
      expect: () => [
        isA<CheckoutState>()
            .having((s) => s.appliedVoucher, 'appliedVoucher', isNull)
            .having((s) => s.discountAmount, 'discountAmount', 0.0),
      ],
    );
  });
}
