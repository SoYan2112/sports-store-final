import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/usecases/add_address_usecase.dart';
import '../../domain/usecases/delete_address_usecase.dart';
import '../../domain/usecases/get_addresses_usecase.dart';
import '../../domain/usecases/update_address_usecase.dart';
import 'address_state.dart';

/// ============================================================================
/// ADDRESS CUBIT - QUẢN LÝ TRẠNG THÁI SỔ ĐỊA CHỈ NHẬN HÀNG (UC-28, 29, 30, 31)
/// ============================================================================
/// Chịu trách nhiệm:
/// 1. Tải danh sách địa chỉ của người dùng hiện tại ([loadAddresses]).
/// 2. Thêm địa chỉ nhận hàng mới ([addAddress]).
/// 3. Cập nhật thông tin địa chỉ đã có ([updateAddress]).
/// 4. Xóa địa chỉ khỏi sổ địa chỉ ([deleteAddress]).
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

  /// 1. LẤY DANH SÁCH ĐỊA CHỈ GIAO HÀNG (UC-28)
  Future<void> loadAddresses() async {
    emit(const AddressLoading());
    try {
      final list = await getAddressesUseCase();
      emit(AddressLoaded(addresses: list));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  /// 2. THÊM ĐỊA CHỈ MỚI (UC-29)
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

      // Thêm vào cơ sở dữ liệu
      final created = await addAddressUseCase(newAddress);
      // Tải lại danh sách mới nhất
      final updatedList = await getAddressesUseCase();
      emit(AddressAddSuccess(newAddress: created, addresses: updatedList));
      emit(AddressLoaded(addresses: updatedList));
    } catch (e) {
      emit(AddressError('Không thể thêm địa chỉ: ${e.toString()}'));
    }
  }

  /// 3. CẬP NHẬT ĐỊA CHỈ GIAO HÀNG (UC-30)
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

  /// 4. XÓA ĐỊA CHỈ GIAO HÀNG (UC-31)
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
