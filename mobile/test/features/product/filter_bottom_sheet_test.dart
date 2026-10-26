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

  testWidgets('FilterBottomSheet renders all sections properly', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Bộ lọc tìm kiếm'), findsOneWidget);
    expect(find.text('Đặt lại'), findsOneWidget);
    expect(find.text('Khoảng giá'), findsOneWidget);
    expect(find.text('Thương hiệu'), findsOneWidget);
    expect(find.text('Danh mục / Phân loại'), findsOneWidget);
    expect(find.text('Áp dụng bộ lọc'), findsOneWidget);

    // Brands exist
    expect(find.byKey(const Key('filter_brand_Nike')), findsOneWidget);
    expect(find.byKey(const Key('filter_brand_Adidas')), findsOneWidget);

    // Categories exist
    expect(find.byKey(const Key('filter_category_Giày thể thao')), findsOneWidget);
    expect(find.byKey(const Key('filter_category_Áo thể thao')), findsOneWidget);
  });

  testWidgets('Selecting brand, preset price and tapping apply updates FilterCubit', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Select Nike
    final nikeChip = find.byKey(const Key('filter_brand_Nike'));
    await tester.tap(nikeChip);
    await tester.pumpAndSettle();

    // Select preset price "Dưới 2tr"
    final presetChip = find.text('Dưới 2tr');
    await tester.tap(presetChip);
    await tester.pumpAndSettle();

    // Tap apply
    final applyButton = find.byKey(const Key('filter_apply_button'));
    await tester.tap(applyButton);
    await tester.pumpAndSettle();

    // Verify cubit received updates
    expect(filterCubit.state.selectedBrands, contains('Nike'));
    expect(filterCubit.state.minPrice, 0);
    expect(filterCubit.state.maxPrice, 2000000);
  });

  testWidgets('Tapping Reset button clears selections locally', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Start with pre-selected filters in cubit
    filterCubit.updateFilter(
      brands: ['Nike'],
      categories: ['Giày thể thao'],
      minPrice: 1000000,
      maxPrice: 3000000,
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap Reset
    final resetButton = find.byKey(const Key('filter_reset_button'));
    await tester.tap(resetButton);
    await tester.pumpAndSettle();

    // Tap Apply to confirm reset state was applied
    final applyButton = find.byKey(const Key('filter_apply_button'));
    await tester.tap(applyButton);
    await tester.pumpAndSettle();

    expect(filterCubit.state.isDefault, isTrue);
    expect(filterCubit.state.selectedBrands, isEmpty);
    expect(filterCubit.state.selectedCategories, isEmpty);
  });
}
