import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/voucher/domain/entities/voucher_entity.dart';
import 'package:mobile/features/voucher/presentation/widgets/voucher_card.dart';

void main() {
  final now = DateTime.now();

  final tVoucher = VoucherEntity(
    id: 'v_summer20',
    code: 'SUMMER20',
    title: 'Giảm 20% đơn từ 400k',
    description: 'Áp dụng cho đồ thể thao',
    type: VoucherType.percentage,
    discountValue: 20,
    minOrderValue: 400000,
    startDate: now.subtract(const Duration(days: 1)),
    endDate: now.add(const Duration(days: 10)),
  );

  Widget createWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  testWidgets('renders voucher title, code, discount badge and copy button',
      (tester) async {
    await tester.pumpWidget(createWidget(VoucherCard(voucher: tVoucher)));

    expect(find.text('Giảm 20% đơn từ 400k'), findsOneWidget);
    expect(find.text('SUMMER20'), findsOneWidget);
    expect(find.text('-20%'), findsOneWidget);
    expect(find.text('Sao chép'), findsOneWidget);
  });

  testWidgets('tapping copy button triggers copy feedback SnackBar',
      (tester) async {
    await tester.pumpWidget(createWidget(VoucherCard(voucher: tVoucher)));

    await tester.tap(find.text('Sao chép'));
    await tester.pumpAndSettle();

    expect(
      find.text('Đã sao chép mã "SUMMER20" vào khay nhớ tạm!'),
      findsOneWidget,
    );
  });

  testWidgets('renders disabled state when voucher is expired',
      (tester) async {
    final expiredVoucher = VoucherEntity(
      id: 'v_expired',
      code: 'EXPIRED10',
      title: 'Mã đã hết hạn',
      description: 'Không thể sử dụng',
      type: VoucherType.fixedAmount,
      discountValue: 10000,
      minOrderValue: 100000,
      startDate: now.subtract(const Duration(days: 20)),
      endDate: now.subtract(const Duration(days: 2)),
    );

    await tester.pumpWidget(createWidget(VoucherCard(voucher: expiredVoucher)));

    expect(find.text('Mã đã hết hạn'), findsOneWidget);
    expect(find.text('Hết hạn'), findsOneWidget);
    expect(find.text('Đã hết hạn'), findsOneWidget);
  });
}

