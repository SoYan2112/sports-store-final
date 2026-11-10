import 'package:equatable/equatable.dart';
import '../../domain/entities/address_entity.dart';

/// ============================================================================
/// ADDRESS STATE - CÁC TRẠNG THÁI GIAO DIỆN SỔ ĐỊA CHỈ
/// ============================================================================
abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái ban đầu
class AddressInitial extends AddressState {
  const AddressInitial();
}

/// Trạng thái đang tải danh sách địa chỉ
class AddressLoading extends AddressState {
  const AddressLoading();
}

/// Trạng thái đã tải danh sách địa chỉ thành công
class AddressLoaded extends AddressState {
  final List<AddressEntity> addresses;

  const AddressLoaded({required this.addresses});

  @override
  List<Object?> get props => [addresses];
}

/// Trạng thái đang thực hiện thêm địa chỉ mới
class AddressAddLoading extends AddressState {
  const AddressAddLoading();
}

/// Trạng thái thêm địa chỉ mới thành công
class AddressAddSuccess extends AddressState {
  final AddressEntity newAddress;
  final List<AddressEntity> addresses;

  const AddressAddSuccess({
    required this.newAddress,
    required this.addresses,
  });

  @override
  List<Object?> get props => [newAddress, addresses];
}

/// Trạng thái đang thực hiện cập nhật địa chỉ
class AddressUpdateLoading extends AddressState {
  const AddressUpdateLoading();
}

/// Trạng thái cập nhật địa chỉ thành công
class AddressUpdateSuccess extends AddressState {
  final AddressEntity updatedAddress;
  final List<AddressEntity> addresses;

  const AddressUpdateSuccess({
    required this.updatedAddress,
    required this.addresses,
  });

  @override
  List<Object?> get props => [updatedAddress, addresses];
}

/// Trạng thái đang thực hiện xóa địa chỉ
class AddressDeleteLoading extends AddressState {
  const AddressDeleteLoading();
}

/// Trạng thái xóa địa chỉ thành công
class AddressDeleteSuccess extends AddressState {
  final String deletedAddressId;
  final List<AddressEntity> addresses;

  const AddressDeleteSuccess({
    required this.deletedAddressId,
    required this.addresses,
  });

  @override
  List<Object?> get props => [deletedAddressId, addresses];
}

/// Trạng thái xảy ra lỗi thao tác địa chỉ
class AddressError extends AddressState {
  final String message;

  const AddressError(this.message);

  @override
  List<Object?> get props => [message];
}
