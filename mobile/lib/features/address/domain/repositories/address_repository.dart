import '../entities/address_entity.dart';

abstract class AddressRepository {
  /// Lấy danh sách địa chỉ giao hàng của người dùng
  Future<List<AddressEntity>> getAddresses();

  /// Thêm địa chỉ giao hàng mới (UC-10)
  Future<AddressEntity> addAddress(AddressEntity address);

  /// Cập nhật địa chỉ giao hàng (UC-18)
  Future<AddressEntity> updateAddress(AddressEntity address);

  /// Xóa địa chỉ giao hàng (UC-19)
  Future<void> deleteAddress(String addressId);

  /// Đặt làm địa chỉ mặc định
  Future<void> setDefaultAddress(String addressId);
}
