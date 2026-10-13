import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/currency_formatter.dart';
import 'package:mobile/features/product/domain/entities/product_entity.dart';
import 'package:mobile/features/product/presentation/widgets/product_card.dart';

void main() {
  testWidgets('ProductCard displays title, brand, badge and formatted VND price',
      (WidgetTester tester) async {
    const product = ProductEntity(
      id: 'p1',
      name: 'Nike unveil joyride',
      brand: 'Nike',
      price: 1950000,
      imageUrl: 'https://example.com/shoe.png',
      badge: 'Hot',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 300,
            child: ProductCard(product: product),
          ),
        ),
      ),
    );

    // Kiểm tra tên sản phẩm
    expect(find.text('Nike unveil joyride'), findsOneWidget);

    // Kiểm tra tên brand
    expect(find.text('NIKE'), findsOneWidget);

    // Kiểm tra badge
    expect(find.text('Hot'), findsOneWidget);

    // Kiểm tra giá tiền định dạng chuẩn VNĐ (1.950.000 ₫)
    expect(find.text('1.950.000 ₫'), findsOneWidget);
  });

  test('CurrencyFormatter formats VND correctly with dot separator', () {
    expect(CurrencyFormatter.formatVnd(1950000), '1.950.000 ₫');
    expect(CurrencyFormatter.formatVnd(2350000), '2.350.000 ₫');
    expect(CurrencyFormatter.formatVnd(500000), '500.000 ₫');
  });
}
