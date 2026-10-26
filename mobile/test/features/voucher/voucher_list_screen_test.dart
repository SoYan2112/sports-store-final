import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/voucher/domain/entities/voucher_entity.dart';
import 'package:mobile/features/voucher/domain/usecases/get_vouchers_usecase.dart';
import 'package:mobile/features/voucher/presentation/cubit/voucher_cubit.dart';
import 'package:mobile/features/voucher/presentation/screens/voucher_list_screen.dart';
import 'package:mobile/features/voucher/presentation/widgets/voucher_card.dart';

class MockGetVouchersUseCase extends Mock implements GetVouchersUseCase {}

void main() {
  late MockGetVouchersUseCase mockGetVouchersUseCase;
  late VoucherCubit voucherCubit;

  final now = DateTime.now();
  final tVouchers = [
    VoucherEntity(
      id: 'v_summer20',
      code: 'SUMMER20',
      title: 'Giảm 20% đơn từ 400k',
      description: 'Áp dụng cho đồ thể thao',
      type: VoucherType.percentage,
      discountValue: 20,
      minOrderValue: 400000,
      startDate: now.subtract(const Duration(days: 1)),
      endDate: now.add(const Duration(days: 10)),
    ),
    VoucherEntity(
      id: 'v_freeship',
      code: 'FREESHIP',
      title: 'Miễn phí vận chuyển',
      description: 'Freeship đơn từ 300k',
      type: VoucherType.freeShipping,
      discountValue: 35000,
      minOrderValue: 300000,
      startDate: now.subtract(const Duration(days: 1)),
      endDate: now.add(const Duration(days: 10)),
    ),
  ];

  setUp(() {
    mockGetVouchersUseCase = MockGetVouchersUseCase();
    voucherCubit = VoucherCubit(getVouchersUseCase: mockGetVouchersUseCase);
  });

  tearDown(() {
    voucherCubit.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: VoucherListScreen(cubit: voucherCubit),
    );
  }

  testWidgets('renders AppBar with title "Kho Voucher & Ưu Đãi"',
      (WidgetTester tester) async {
    when(() => mockGetVouchersUseCase()).thenAnswer((_) async => tVouchers);

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Kho Voucher & Ưu Đãi'), findsOneWidget);
  });

  testWidgets('renders voucher list, search bar, and filter chips when vouchers loaded',
      (WidgetTester tester) async {
    when(() => mockGetVouchersUseCase()).thenAnswer((_) async => tVouchers);

    await tester.pumpWidget(createWidgetUnderTest());
    await voucherCubit.fetchVouchers();
    await tester.pumpAndSettle();

    expect(find.byType(VoucherCard), findsNWidgets(2));
    expect(find.text('Tìm kiếm voucher theo tên, mã...'), findsOneWidget);
    expect(find.text('Tất cả (2)'), findsOneWidget);
    expect(find.text('Giảm giá'), findsOneWidget);
    expect(find.text('Freeship'), findsOneWidget);
  });

  testWidgets('filtering vouchers by Freeship chip works',
      (WidgetTester tester) async {
    when(() => mockGetVouchersUseCase()).thenAnswer((_) async => tVouchers);

    await tester.pumpWidget(createWidgetUnderTest());
    await voucherCubit.fetchVouchers();
    await tester.pumpAndSettle();

    // Tap Freeship chip
    await tester.tap(find.text('Freeship'));
    await tester.pumpAndSettle();

    // Only 1 Freeship voucher is displayed
    expect(find.byType(VoucherCard), findsOneWidget);
    expect(find.text('FREESHIP'), findsWidgets);
    expect(find.text('SUMMER20'), findsNothing);
  });

  testWidgets('searching vouchers by query filters list in real time',
      (WidgetTester tester) async {
    when(() => mockGetVouchersUseCase()).thenAnswer((_) async => tVouchers);

    await tester.pumpWidget(createWidgetUnderTest());
    await voucherCubit.fetchVouchers();
    await tester.pumpAndSettle();

    // Enter search text SUMMER
    await tester.enterText(find.byType(TextField), 'SUMMER');
    await tester.pumpAndSettle();

    expect(find.byType(VoucherCard), findsOneWidget);
    expect(find.text('SUMMER20'), findsOneWidget);
    expect(find.text('FREESHIP'), findsNothing);

    // Clear search using clear button
    await tester.tap(find.byIcon(Icons.cancel));
    await tester.pumpAndSettle();

    // Both vouchers restored
    expect(find.byType(VoucherCard), findsNWidgets(2));
  });

  testWidgets('searching non-existent voucher shows empty search view with clear action',
      (WidgetTester tester) async {
    when(() => mockGetVouchersUseCase()).thenAnswer((_) async => tVouchers);

    await tester.pumpWidget(createWidgetUnderTest());
    await voucherCubit.fetchVouchers();
    await tester.pumpAndSettle();

    // Enter query that doesn't match
    await tester.enterText(find.byType(TextField), 'XYZ123');
    await tester.pumpAndSettle();

    expect(find.byType(VoucherCard), findsNothing);
    expect(find.text('Không tìm thấy voucher phù hợp'), findsOneWidget);
    expect(find.text('Xóa tìm kiếm'), findsOneWidget);

    // Tap "Xóa tìm kiếm" button
    await tester.tap(find.text('Xóa tìm kiếm'));
    await tester.pumpAndSettle();

    expect(find.byType(VoucherCard), findsNWidgets(2));
  });

  testWidgets('renders error message and retry button on failure',
      (WidgetTester tester) async {
    when(() => mockGetVouchersUseCase())
        .thenThrow(Exception('Network error'));

    await tester.pumpWidget(createWidgetUnderTest());
    await voucherCubit.fetchVouchers();
    await tester.pumpAndSettle();

    expect(
      find.text('Không thể tải danh sách voucher ưu đãi. Vui lòng thử lại.'),
      findsOneWidget,
    );
    expect(find.text('Thử lại'), findsOneWidget);
  });
}
