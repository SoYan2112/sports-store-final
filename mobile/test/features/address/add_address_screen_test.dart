import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/address/presentation/cubit/address_cubit.dart';
import 'package:mobile/features/address/presentation/cubit/address_state.dart';
import 'package:mobile/features/address/presentation/screens/add_address_screen.dart';

class MockAddressCubit extends Mock implements AddressCubit {}

void main() {
  late MockAddressCubit mockAddressCubit;

  setUp(() {
    mockAddressCubit = MockAddressCubit();
    when(() => mockAddressCubit.state).thenReturn(const AddressInitial());
    when(() => mockAddressCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider<AddressCubit>.value(
        value: mockAddressCubit,
        child: const AddAddressScreen(),
      ),
    );
  }

  group('AddAddressScreen Widget Tests', () {
    testWidgets('renders all input fields and action buttons', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Địa chỉ mới'), findsOneWidget);
      expect(find.byKey(const Key('recipientNameField')), findsOneWidget);
      expect(find.byKey(const Key('phoneNumberField')), findsOneWidget);
      expect(find.byKey(const Key('areaSelectorTile')), findsOneWidget);
      expect(find.byKey(const Key('streetAddressField')), findsOneWidget);
      expect(find.byKey(const Key('saveAddressButton')), findsOneWidget);
      expect(find.text('HOÀN THÀNH'), findsOneWidget);
    });

    testWidgets('shows validation errors when submitting empty form',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // Tap nút lưu khi chưa điền dữ liệu
      await tester.tap(find.byKey(const Key('saveAddressButton')));
      await tester.pumpAndSettle();

      expect(
        find.text('Vui lòng nhập họ và tên người nhận'),
        findsOneWidget,
      );
      expect(
        find.text('Vui lòng nhập số điện thoại người nhận'),
        findsOneWidget,
      );
      expect(
        find.text('Vui lòng chọn Tỉnh/Thành phố, Quận/Huyện, Phường/Xã'),
        findsOneWidget,
      );
      expect(
        find.text('Vui lòng nhập số nhà, tên đường cụ thể'),
        findsOneWidget,
      );

      // Verify cubit.addAddress was NOT called
      verifyNever(() => mockAddressCubit.addAddress(
            recipientName: any(named: 'recipientName'),
            phoneNumber: any(named: 'phoneNumber'),
            province: any(named: 'province'),
            district: any(named: 'district'),
            ward: any(named: 'ward'),
            streetAddress: any(named: 'streetAddress'),
          ));
    });

    testWidgets('shows error for invalid Vietnamese phone number',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.enterText(
        find.byKey(const Key('recipientNameField')),
        'Trần Hoàng Nhật',
      );
      await tester.enterText(
        find.byKey(const Key('phoneNumberField')),
        '12345', // Số không đúng chuẩn VN
      );
      await tester.tap(find.byKey(const Key('saveAddressButton')));
      await tester.pumpAndSettle();

      expect(
        find.text('Số điện thoại không hợp lệ (ví dụ: 0901234567)'),
        findsOneWidget,
      );
    });
  });
}
