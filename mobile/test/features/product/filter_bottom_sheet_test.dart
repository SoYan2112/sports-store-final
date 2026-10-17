import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/product/presentation/cubit/filter_cubit.dart';
import 'package:mobile/features/product/presentation/widgets/filter_bottom_sheet.dart';

void main() {
  late FilterCubit filterCubit;

  setUp(() {
    filterCubit = FilterCubit();
  });

  tearDown(() {
    filterCubit.close();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<FilterCubit>.value(
          value: filterCubit,
          child: const FilterBottomSheet(),
        ),
      ),
    );
  }

  testWidgets('FilterBottomSheet renders title, brands, and action buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());

    expect(find.text('Bộ lọc sản phẩm'), findsOneWidget);
    expect(find.text('Thương hiệu'), findsOneWidget);
    expect(find.text('Khoảng giá'), findsOneWidget);
    expect(find.text('Tất cả'), findsOneWidget);
    expect(find.text('Nike'), findsOneWidget);
    expect(find.text('Adidas'), findsOneWidget);
    expect(find.text('Đặt lại'), findsOneWidget);
    expect(find.text('Áp dụng'), findsOneWidget);
  });

  testWidgets('Selecting a brand and clicking Áp dụng updates FilterCubit',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());

    // Tap on Nike chip
    await tester.tap(find.text('Nike'));
    await tester.pump();

    // Tap on Áp dụng button
    await tester.tap(find.text('Áp dụng'));
    await tester.pumpAndSettle();

    expect(filterCubit.state.selectedBrand, 'Nike');
  });

  testWidgets('Clicking Đặt lại resets FilterCubit state',
      (WidgetTester tester) async {
    // Seed with non-default
    filterCubit.updateFilter(
      brand: 'Puma',
      minPrice: 1000000,
      maxPrice: 3000000,
    );

    await tester.pumpWidget(buildTestWidget());

    // Tap on Đặt lại button
    await tester.tap(find.text('Đặt lại'));
    await tester.pumpAndSettle();

    expect(filterCubit.state.selectedBrand, 'Tất cả');
    expect(filterCubit.state.minPrice, 0);
    expect(filterCubit.state.maxPrice, 5000000);
    expect(filterCubit.state.isDefault, isTrue);
  });
}
