import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/errors/exceptions.dart';
import 'package:mobile/core/storage/local_storage_service.dart';
import 'package:mobile/features/address/domain/entities/address_entity.dart';
import 'package:mobile/features/order/data/datasources/order_remote_datasource.dart';
import 'package:mobile/features/order/data/models/order_model.dart';
import 'package:mobile/features/order/domain/entities/order_entity.dart';
import 'package:mobile/features/order/domain/repositories/order_repository.dart';
import 'package:mobile/features/order/domain/usecases/cancel_order_usecase.dart';
import 'package:mobile/features/order/presentation/cubit/cancel_order_cubit.dart';
import 'package:mobile/features/order/presentation/cubit/cancel_order_state.dart';
import 'package:mobile/features/order/presentation/screens/order_detail_screen.dart';

class MockOrderRepository extends Mock implements OrderRepository {}
class MockCancelOrderUseCase extends Mock implements CancelOrderUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockOrderRepository mockOrderRepository;
  late MockCancelOrderUseCase mockCancelOrderUseCase;
  late CancelOrderCubit cancelOrderCubit;

  const testAddress = AddressEntity(
    id: 'addr_1',
    recipientName: 'Nguyen Van A',
    phoneNumber: '0901234567',
    province: 'TP.HCM',
    district: 'Quận 1',
    ward: 'Phường Bến Nghé',
    streetAddress: '123 Le Loi',
    label: AddressLabel.home,
    isDefault: true,
  );

  final testOrder = OrderEntity(
    id: 'SS000123',
    userId: 'user_1',
    status: 'Đã hủy',
    createdAt: DateTime.now(),
    subtotal: 500000,
    shippingFee: 30000,
    discountAmount: 0,
    totalAmount: 530000,
    shippingAddress: testAddress,
    paymentMethod: PaymentMethod.cod,
    shippingMethod: ShippingMethod.standard,
    items: const [],
  );

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    mockCancelOrderUseCase = MockCancelOrderUseCase();
    cancelOrderCubit = CancelOrderCubit(cancelOrderUseCase: mockCancelOrderUseCase);

    if (getIt.isRegistered<OrderRepository>()) {
      getIt.unregister<OrderRepository>();
    }
    getIt.registerSingleton<OrderRepository>(mockOrderRepository);

    if (getIt.isRegistered<CancelOrderCubit>()) {
      getIt.unregister<CancelOrderCubit>();
    }
    getIt.registerFactory<CancelOrderCubit>(
      () => CancelOrderCubit(cancelOrderUseCase: mockCancelOrderUseCase),
    );

    when(() => mockOrderRepository.getOrders()).thenAnswer((_) async => []);
  });

  tearDown(() {
    cancelOrderCubit.close();
    getIt.reset();
  });

  group('CancelOrderCubit Tests (UC-20)', () {
    test('Initial state is CancelOrderInitial', () {
      expect(cancelOrderCubit.state, equals(const CancelOrderInitial()));
    });

    test('Emits [CancelOrderLoading, CancelOrderSuccess] when cancel succeeds', () async {
      when(() => mockCancelOrderUseCase(
            any(),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async => testOrder);

      final expectedStates = [
        const CancelOrderLoading(),
        const CancelOrderSuccess(
          orderId: 'SS000123',
          message: 'Đơn hàng #SS000123 đã được hủy thành công',
        ),
      ];

      expectLater(cancelOrderCubit.stream, emitsInOrder(expectedStates));

      await cancelOrderCubit.cancelOrder('SS000123', reason: 'Muốn đổi size khác');
    });

    test('Emits [CancelOrderLoading, CancelOrderError] when cancel fails', () async {
      when(() => mockCancelOrderUseCase(
            any(),
            reason: any(named: 'reason'),
          )).thenThrow(const ServerException(message: 'Đơn hàng đang giao, không thể hủy.'));

      final expectedStates = [
        const CancelOrderLoading(),
        isA<CancelOrderError>(),
      ];

      expectLater(cancelOrderCubit.stream, emitsInOrder(expectedStates));

      await cancelOrderCubit.cancelOrder('SS000123');
    });

    test('reset() emits CancelOrderInitial', () {
      cancelOrderCubit.reset();
      expect(cancelOrderCubit.state, equals(const CancelOrderInitial()));
    });
  });

  group('OrderRemoteDataSourceImpl cancelOrder (UC-20)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Hủy thành công đơn hàng chờ xác nhận và lưu vào SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      await storageService.saveAuthSession(
        token: 'token_123',
        userId: 'u_test',
        name: 'Tester',
        email: 'test@example.com',
      );

      final dataSource = OrderRemoteDataSourceImpl(
        sharedPreferences: prefs,
        storageService: storageService,
      );

      final initialOrder = OrderModel(
        id: 'ord_999',
        userId: 'u_test',
        status: 'Chờ xác nhận',
        createdAt: DateTime.now(),
        subtotal: 200000,
        shippingFee: 20000,
        discountAmount: 0,
        totalAmount: 220000,
        shippingAddress: testAddress,
        paymentMethod: PaymentMethod.cod,
        shippingMethod: ShippingMethod.standard,
        items: const [],
      );

      await dataSource.createOrder(initialOrder.toJson());

      final cancelledOrder = await dataSource.cancelOrder('ord_999', reason: 'Đổi ý');
      expect(cancelledOrder.status, equals('Đã hủy'));

      final savedOrders = await dataSource.getOrders();
      expect(savedOrders.first.status, equals('Đã hủy'));
    });

    test('Chặn hủy và ném ngoại lệ nếu đơn đã giao hoặc đang giao', () async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = LocalStorageService(prefs);
      await storageService.saveAuthSession(
        token: 'token_123',
        userId: 'u_test',
        name: 'Tester',
        email: 'test@example.com',
      );

      final dataSource = OrderRemoteDataSourceImpl(
        sharedPreferences: prefs,
        storageService: storageService,
      );

      final shippingOrder = OrderModel(
        id: 'ord_888',
        userId: 'u_test',
        status: 'Đang giao',
        createdAt: DateTime.now(),
        subtotal: 200000,
        shippingFee: 20000,
        discountAmount: 0,
        totalAmount: 220000,
        shippingAddress: testAddress,
        paymentMethod: PaymentMethod.cod,
        shippingMethod: ShippingMethod.standard,
        items: const [],
      );

      await dataSource.createOrder(shippingOrder.toJson());

      expect(
        () => dataSource.cancelOrder('ord_888'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('OrderDetailScreen Widget Tests (UC-20 UI Workflow)', () {
    testWidgets('Hiển thị nút hủy và cập nhật trạng thái khi xác nhận hủy', (tester) async {
      when(() => mockCancelOrderUseCase('SS000123', reason: any(named: 'reason')))
          .thenAnswer((_) async => testOrder);

      String? updatedStatus;

      await tester.pumpWidget(
        MaterialApp(
          home: OrderDetailScreen(
            orderId: 'SS000123',
            date: '25/10/2026',
            status: 'Chờ xác nhận',
            statusColor: Colors.orange,
            productName: 'Giày Nike Air Zoom Pegasus',
            productInfo: 'Size 42 - Đen - x1',
            total: '2.500.000 ₫',
            icon: Icons.directions_run_rounded,
            onStatusChanged: (status) {
              updatedStatus = status;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('HỦY ĐƠN HÀNG'), findsOneWidget);

      await tester.tap(find.text('HỦY ĐƠN HÀNG'));
      await tester.pumpAndSettle();
      expect(find.text('Xác nhận hủy đơn'), findsOneWidget);

      await tester.tap(find.text('Xác nhận hủy'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Đã hủy'), findsOneWidget);
      expect(find.text('HỦY ĐƠN HÀNG'), findsNothing);
      expect(find.text('Đơn hàng này đã được hủy thành công.'), findsOneWidget);
      expect(updatedStatus, equals('Đã hủy'));
    });

    testWidgets('Ẩn nút hủy với đơn hàng đang giao', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OrderDetailScreen(
            orderId: 'SS000122',
            date: '22/10/2026',
            status: 'Đang giao',
            statusColor: Colors.blue,
            productName: 'Áo thể thao Adidas',
            productInfo: 'Size L - Trắng - x2',
            total: '1.200.000 ₫',
            icon: Icons.checkroom_rounded,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('HỦY ĐƠN HÀNG'), findsNothing);
      expect(find.text('Đơn hàng đang giao, không thể hủy.'), findsOneWidget);
    });
  });
}
