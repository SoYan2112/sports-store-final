import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/address/domain/entities/address_entity.dart';
import 'package:mobile/features/address/domain/usecases/add_address_usecase.dart';
import 'package:mobile/features/address/domain/usecases/delete_address_usecase.dart';
import 'package:mobile/features/address/domain/usecases/get_addresses_usecase.dart';
import 'package:mobile/features/address/domain/usecases/update_address_usecase.dart';
import 'package:mobile/features/address/presentation/cubit/address_cubit.dart';
import 'package:mobile/features/address/presentation/cubit/address_state.dart';

class MockGetAddressesUseCase extends Mock implements GetAddressesUseCase {}
class MockAddAddressUseCase extends Mock implements AddAddressUseCase {}
class MockUpdateAddressUseCase extends Mock implements UpdateAddressUseCase {}
class MockDeleteAddressUseCase extends Mock implements DeleteAddressUseCase {}

class FakeAddressEntity extends Fake implements AddressEntity {}

void main() {
  late MockGetAddressesUseCase mockGetAddressesUseCase;
  late MockAddAddressUseCase mockAddAddressUseCase;
  late MockUpdateAddressUseCase mockUpdateAddressUseCase;
  late MockDeleteAddressUseCase mockDeleteAddressUseCase;
  late AddressCubit addressCubit;

  const tAddress = AddressEntity(
    id: 'addr_001',
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
    registerFallbackValue(FakeAddressEntity());
  });

  setUp(() {
    mockGetAddressesUseCase = MockGetAddressesUseCase();
    mockAddAddressUseCase = MockAddAddressUseCase();
    mockUpdateAddressUseCase = MockUpdateAddressUseCase();
    mockDeleteAddressUseCase = MockDeleteAddressUseCase();
    addressCubit = AddressCubit(
      getAddressesUseCase: mockGetAddressesUseCase,
      addAddressUseCase: mockAddAddressUseCase,
      updateAddressUseCase: mockUpdateAddressUseCase,
      deleteAddressUseCase: mockDeleteAddressUseCase,
    );
  });

  tearDown(() {
    addressCubit.close();
  });

  group('AddressCubit', () {
    test('initial state should be AddressInitial', () {
      expect(addressCubit.state, const AddressInitial());
    });

    blocTest<AddressCubit, AddressState>(
      'emits [AddressLoading, AddressLoaded] when loadAddresses succeeds',
      build: () {
        when(() => mockGetAddressesUseCase())
            .thenAnswer((_) async => [tAddress]);
        return addressCubit;
      },
      act: (cubit) => cubit.loadAddresses(),
      expect: () => [
        const AddressLoading(),
        const AddressLoaded(addresses: [tAddress]),
      ],
      verify: (_) {
        verify(() => mockGetAddressesUseCase()).called(1);
      },
    );

    blocTest<AddressCubit, AddressState>(
      'emits [AddressLoading, AddressError] when loadAddresses fails',
      build: () {
        when(() => mockGetAddressesUseCase())
            .thenThrow(Exception('Lỗi kết nối'));
        return addressCubit;
      },
      act: (cubit) => cubit.loadAddresses(),
      expect: () => [
        const AddressLoading(),
        const AddressError('Exception: Lỗi kết nối'),
      ],
      verify: (_) {
        verify(() => mockGetAddressesUseCase()).called(1);
      },
    );

    blocTest<AddressCubit, AddressState>(
      'emits [AddressAddLoading, AddressAddSuccess, AddressLoaded] when addAddress succeeds',
      build: () {
        when(() => mockAddAddressUseCase(any()))
            .thenAnswer((_) async => tAddress);
        when(() => mockGetAddressesUseCase())
            .thenAnswer((_) async => [tAddress]);
        return addressCubit;
      },
      act: (cubit) => cubit.addAddress(
        recipientName: 'Trần Hoàng Nhật',
        phoneNumber: '0905123456',
        province: 'TP. Hồ Chí Minh',
        district: 'Quận 1',
        ward: 'Phường Bến Nghé',
        streetAddress: '123 Đường Lê Duẩn',
        label: AddressLabel.home,
        isDefault: true,
      ),
      expect: () => [
        const AddressAddLoading(),
        const AddressAddSuccess(
          newAddress: tAddress,
          addresses: [tAddress],
        ),
        const AddressLoaded(addresses: [tAddress]),
      ],
      verify: (_) {
        verify(() => mockAddAddressUseCase(any())).called(1);
        verify(() => mockGetAddressesUseCase()).called(1);
      },
    );

    blocTest<AddressCubit, AddressState>(
      'emits [AddressUpdateLoading, AddressUpdateSuccess, AddressLoaded] when updateAddress succeeds',
      build: () {
        when(() => mockUpdateAddressUseCase(any()))
            .thenAnswer((_) async => tAddress);
        when(() => mockGetAddressesUseCase())
            .thenAnswer((_) async => [tAddress]);
        return addressCubit;
      },
      act: (cubit) => cubit.updateAddress(
        id: 'addr_001',
        recipientName: 'Trần Hoàng Nhật',
        phoneNumber: '0905123456',
        province: 'TP. Hồ Chí Minh',
        district: 'Quận 1',
        ward: 'Phường Bến Nghé',
        streetAddress: '123 Đường Lê Duẩn',
        label: AddressLabel.home,
        isDefault: true,
      ),
      expect: () => [
        const AddressUpdateLoading(),
        AddressUpdateSuccess(
          updatedAddress: tAddress,
          addresses: const [tAddress],
        ),
        const AddressLoaded(addresses: [tAddress]),
      ],
      verify: (_) {
        verify(() => mockUpdateAddressUseCase(any())).called(1);
        verify(() => mockGetAddressesUseCase()).called(1);
      },
    );

    blocTest<AddressCubit, AddressState>(
      'emits [AddressDeleteLoading, AddressDeleteSuccess, AddressLoaded] when deleteAddress succeeds',
      build: () {
        when(() => mockDeleteAddressUseCase(any()))
            .thenAnswer((_) async {});
        when(() => mockGetAddressesUseCase())
            .thenAnswer((_) async => []);
        return addressCubit;
      },
      act: (cubit) => cubit.deleteAddress('addr_001'),
      expect: () => [
        const AddressDeleteLoading(),
        const AddressDeleteSuccess(
          deletedAddressId: 'addr_001',
          addresses: [],
        ),
        const AddressLoaded(addresses: []),
      ],
      verify: (_) {
        verify(() => mockDeleteAddressUseCase('addr_001')).called(1);
        verify(() => mockGetAddressesUseCase()).called(1);
      },
    );

    blocTest<AddressCubit, AddressState>(
      'emits [AddressDeleteLoading, AddressError] when deleteAddress fails',
      build: () {
        when(() => mockDeleteAddressUseCase(any()))
            .thenThrow(Exception('Không thể xóa địa chỉ'));
        return addressCubit;
      },
      act: (cubit) => cubit.deleteAddress('addr_001'),
      expect: () => [
        const AddressDeleteLoading(),
        const AddressError('Không thể xóa địa chỉ: Exception: Không thể xóa địa chỉ'),
      ],
      verify: (_) {
        verify(() => mockDeleteAddressUseCase('addr_001')).called(1);
      },
    );
  });
}
