import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/usecases/add_address_usecase.dart';
import '../../domain/usecases/get_addresses_usecase.dart';
import 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final GetAddressesUseCase getAddressesUseCase;
  final AddAddressUseCase addAddressUseCase;

  AddressCubit({
    required this.getAddressesUseCase,
    required this.addAddressUseCase,
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
}
