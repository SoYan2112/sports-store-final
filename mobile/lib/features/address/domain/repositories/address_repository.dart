import '../entities/address_entity.dart';

/// ============================================================================
/// ADDRESS REPOSITORY INTERFACE (DOMAIN LAYER)
/// ============================================================================
/// Hợp đồng trừu tượng định nghĩa các hành động với sổ địa chỉ.
abstract class AddressRepository {
  /// Lấy toàn bộ danh sách địa chỉ giao hàng của người dùng
  Future<List<AddressEntity>> getAddresses();

  /// Thêm một địa chỉ nhận hàng mới
  Future<AddressEntity> addAddress(AddressEntity address);

  /// Cập nhật thông tin một địa chỉ đã có
  Future<AddressEntity> updateAddress(AddressEntity address);

  /// Xóa địa chỉ theo mã định danh (id)
  Future<void> deleteAddress(String addressId);

  /// Đặt một địa chỉ làm địa chỉ mặc định
  Future<void> setDefaultAddress(String addressId);
}
