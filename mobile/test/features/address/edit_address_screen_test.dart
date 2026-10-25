import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/address/domain/entities/address_entity.dart';
import 'package:mobile/features/address/presentation/cubit/address_cubit.dart';
import 'package:mobile/features/address/presentation/cubit/address_state.dart';
import 'package:mobile/features/address/presentation/screens/edit_address_screen.dart';

class MockAddressCubit extends Mock implements AddressCubit {}

void main() {
  late MockAddressCubit mockAddressCubit;

  const tExistingAddress = AddressEntity(
    id: 'addr_sample_01',
    recipientName: 'Trần Hoàng Nhật',
    phoneNumber: '0905123456',
    province: 'TP. Hồ Chí Minh',
    district: 'Quận 1',
    ward: 'Phường Bến Nghé',
    streetAddress: '123 Đường Lê Duẩn',
    label: AddressLabel.home,
    isDefault: true,
  );

  setUpAll(() {
    registerFallbackValue(AddressLabel.home);
  });

  setUp(() {
    mockAddressCubit = MockAddressCubit();
    when(() => mockAddressCubit.state).thenReturn(const AddressInitial());
    when(() => mockAddressCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider<AddressCubit>.value(
        value: mockAddressCubit,
        child: const EditAddressScreen(address: tExistingAddress),
      ),
    );
  }

  group('EditAddressScreen Widget Tests', () {
    testWidgets('renders all fields with pre-filled existing address data',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Chỉnh sửa địa chỉ'), findsOneWidget);
      expect(find.byKey(const Key('editRecipientNameField')), findsOneWidget);
      expect(find.byKey(const Key('editPhoneNumberField')), findsOneWidget);
      expect(find.byKey(const Key('editAreaSelectorTile')), findsOneWidget);
      expect(find.byKey(const Key('editStreetAddressField')), findsOneWidget);
      expect(find.byKey(const Key('updateAddressButton')), findsOneWidget);
      expect(find.text('CẬP NHẬT'), findsOneWidget);

      // Kiểm tra dữ liệu cũ đã được điền sẵn
      expect(find.text('Trần Hoàng Nhật'), findsOneWidget);
      expect(find.text('0905123456'), findsOneWidget);
      expect(find.text('123 Đường Lê Duẩn'), findsOneWidget);
      expect(
        find.text('Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh'),
        findsOneWidget,
      );
    });

    testWidgets('calls cubit.updateAddress when form is submitted with valid data',
        (tester) async {
      when(() => mockAddressCubit.updateAddress(
            id: any(named: 'id'),
            recipientName: any(named: 'recipientName'),
            phoneNumber: any(named: 'phoneNumber'),
            province: any(named: 'province'),
            district: any(named: 'district'),
            ward: any(named: 'ward'),
            streetAddress: any(named: 'streetAddress'),
            label: any(named: 'label'),
            isDefault: any(named: 'isDefault'),
          )).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestableWidget());

      // Nhấn nút Cập nhật
      await tester.tap(find.byKey(const Key('updateAddressButton')));
      await tester.pumpAndSettle();

      verify(() => mockAddressCubit.updateAddress(
            id: 'addr_sample_01',
            recipientName: 'Trần Hoàng Nhật',
            phoneNumber: '0905123456',
            province: 'TP. Hồ Chí Minh',
            district: 'Quận 1',
            ward: 'Phường Bến Nghé',
            streetAddress: '123 Đường Lê Duẩn',
            label: AddressLabel.home,
            isDefault: true,
          )).called(1);
    });

    testWidgets('shows validation error when recipient name is cleared',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      // Xóa tên người nhận
      await tester.enterText(
        find.byKey(const Key('editRecipientNameField')),
        '',
      );
      await tester.tap(find.byKey(const Key('updateAddressButton')));
      await tester.pumpAndSettle();

      expect(
        find.text('Vui lòng nhập họ và tên người nhận'),
        findsOneWidget,
      );

      verifyNever(() => mockAddressCubit.updateAddress(
            id: any(named: 'id'),
            recipientName: any(named: 'recipientName'),
            phoneNumber: any(named: 'phoneNumber'),
            province: any(named: 'province'),
            district: any(named: 'district'),
            ward: any(named: 'ward'),
            streetAddress: any(named: 'streetAddress'),
            label: any(named: 'label'),
            isDefault: any(named: 'isDefault'),
          ));
    });
  });
}
