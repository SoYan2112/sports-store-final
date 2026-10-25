import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/usecases/add_address_usecase.dart';
import '../../domain/usecases/delete_address_usecase.dart';
import '../../domain/usecases/get_addresses_usecase.dart';
import '../../domain/usecases/update_address_usecase.dart';
import 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final GetAddressesUseCase getAddressesUseCase;
  final AddAddressUseCase addAddressUseCase;
  final UpdateAddressUseCase updateAddressUseCase;
  final DeleteAddressUseCase deleteAddressUseCase;

  AddressCubit({
    required this.getAddressesUseCase,
    required this.addAddressUseCase,
    required this.updateAddressUseCase,
    required this.deleteAddressUseCase,
  }) : super(const AddressInitial());

  /// Lấy danh sách địa chỉ giao hàng
  Future<void> loadAddresses() async {
    emit(const AddressLoading());
    try {
      final list = await getAddressesUseCase();
      emit(AddressLoaded(addresses: list));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  /// Thêm địa chỉ mới (UC-10)
  Future<void> addAddress({
    required String recipientName,
    required String phoneNumber,
    required String province,
    required String district,
    required String ward,
    required String streetAddress,
    AddressLabel label = AddressLabel.home,
    bool isDefault = false,
  }) async {
    emit(const AddressAddLoading());
    try {
      final newAddress = AddressEntity(
        id: '',
        recipientName: recipientName.trim(),
        phoneNumber: phoneNumber.trim(),
        province: province.trim(),
        district: district.trim(),
        ward: ward.trim(),
        streetAddress: streetAddress.trim(),
        label: label,
        isDefault: isDefault,
      );

      final created = await addAddressUseCase(newAddress);
      final updatedList = await getAddressesUseCase();
      emit(AddressAddSuccess(newAddress: created, addresses: updatedList));
      emit(AddressLoaded(addresses: updatedList));
    } catch (e) {
      emit(AddressError('Không thể thêm địa chỉ: ${e.toString()}'));
    }
  }

  /// Cập nhật địa chỉ giao hàng (UC-18)
  Future<void> updateAddress({
    required String id,
    required String recipientName,
    required String phoneNumber,
    required String province,
    required String district,
    required String ward,
    required String streetAddress,
    AddressLabel label = AddressLabel.home,
    bool isDefault = false,
  }) async {
    emit(const AddressUpdateLoading());
    try {
      final updatedAddress = AddressEntity(
        id: id,
        recipientName: recipientName.trim(),
        phoneNumber: phoneNumber.trim(),
        province: province.trim(),
        district: district.trim(),
        ward: ward.trim(),
        streetAddress: streetAddress.trim(),
        label: label,
        isDefault: isDefault,
      );

      final updated = await updateAddressUseCase(updatedAddress);
      final updatedList = await getAddressesUseCase();
      emit(AddressUpdateSuccess(
        updatedAddress: updated,
        addresses: updatedList,
      ));
      emit(AddressLoaded(addresses: updatedList));
    } catch (e) {
      emit(AddressError('Không thể cập nhật địa chỉ: ${e.toString()}'));
    }
  }

  /// Xóa địa chỉ giao hàng (UC-19)
  Future<void> deleteAddress(String addressId) async {
    emit(const AddressDeleteLoading());
    try {
      await deleteAddressUseCase(addressId);
      final updatedList = await getAddressesUseCase();
      emit(AddressDeleteSuccess(
        deletedAddressId: addressId,
        addresses: updatedList,
      ));
      emit(AddressLoaded(addresses: updatedList));
    } catch (e) {
      emit(AddressError('Không thể xóa địa chỉ: ${e.toString()}'));
    }
  }
}
