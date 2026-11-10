import '../../../../core/database/app_database.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../domain/entities/address_entity.dart';
import '../models/address_model.dart';
import 'address_remote_datasource.dart';

/// ============================================================================
/// ADDRESS LOCAL DATA SOURCE (SQLITE BẢNG shipping_addresses)
/// ============================================================================
/// Thao tác trực tiếp với bảng `shipping_addresses` trong cơ sở dữ liệu SQLite cục bộ.
abstract class AddressLocalDataSource {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> addAddress(AddressModel address);
  Future<AddressModel> updateAddress(AddressModel address);
  Future<void> deleteAddress(String addressId);
  Future<void> setDefaultAddress(String addressId);
}

class AddressLocalDataSourceImpl
    implements AddressLocalDataSource, AddressRemoteDataSource {
  final AppDatabase appDatabase;
  final LocalStorageService? storageService;

  AddressLocalDataSourceImpl({
    AppDatabase? appDatabase,
    this.storageService,
  }) : appDatabase = appDatabase ?? AppDatabase.instance;

  /// Lấy ID người dùng hiện tại đang đăng nhập
  String? _getEffectiveUserId() {
    return storageService?.getUserId();
  }

  /// Ánh xạ một dòng kết quả SQLite sang AddressModel
  AddressModel _mapRowToAddress(Map<String, dynamic> row) {
    return AddressModel(
      id: row['id'] as String,
      recipientName: row['recipient_name'] as String? ?? '',
      phoneNumber: row['phone_number'] as String? ?? '',
      province: row['province'] as String? ?? '',
      district: row['district'] as String? ?? '',
      ward: row['ward'] as String? ?? '',
      streetAddress: row['street_address'] as String? ?? '',
      label: AddressLabel.fromString(row['label'] as String?),
      isDefault: (row['is_default'] as num?)?.toInt() == 1,
    );
  }

  /// 1. LẤY DANH SÁCH ĐỊA CHỈ TỪ SQLITE (Ưu tiên địa chỉ mặc định lên đầu)
  @override
  Future<List<AddressModel>> getAddresses() async {
    final db = await appDatabase.database;
    final userId = _getEffectiveUserId();

    final List<Map<String, dynamic>> results;
    if (userId != null && userId.isNotEmpty) {
      results = await db.query(
        'shipping_addresses',
        where: 'user_id = ? OR user_id IS NULL',
        whereArgs: [userId],
        orderBy: 'is_default DESC, id ASC',
      );
    } else {
      results = await db.query(
        'shipping_addresses',
        orderBy: 'is_default DESC, id ASC',
      );
    }

    return results.map(_mapRowToAddress).toList();
  }

  /// 2. THÊM ĐỊA CHỈ VÀO SQLITE
  @override
  Future<AddressModel> addAddress(AddressModel address) async {
    final db = await appDatabase.database;
    final userId = _getEffectiveUserId() ?? '1';
    final generatedId = address.id.isEmpty || address.id == 'default'
        ? 'addr_${DateTime.now().millisecondsSinceEpoch}'
        : address.id;

    // Nếu đặt làm mặc định -> Hủy cờ mặc định của các địa chỉ cũ
    if (address.isDefault) {
      await db.update(
        'shipping_addresses',
        {'is_default': 0},
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }

    // Chèn bản ghi mới
    await db.insert('shipping_addresses', {
      'id': generatedId,
      'user_id': userId,
      'recipient_name': address.recipientName,
      'phone_number': address.phoneNumber,
      'province': address.province,
      'district': address.district,
      'ward': address.ward,
      'street_address': address.streetAddress,
      'label': address.label.name,
      'is_default': address.isDefault ? 1 : 0,
    });

    return AddressModel(
      id: generatedId,
      recipientName: address.recipientName,
      phoneNumber: address.phoneNumber,
      province: address.province,
      district: address.district,
      ward: address.ward,
      streetAddress: address.streetAddress,
      label: address.label,
      isDefault: address.isDefault,
    );
  }

  /// 3. CẬP NHẬT ĐỊA CHỈ TRONG SQLITE
  @override
  Future<AddressModel> updateAddress(AddressModel address) async {
    final db = await appDatabase.database;
    final userId = _getEffectiveUserId() ?? '1';

    // Nếu đặt làm mặc định -> Reset các địa chỉ khác
    if (address.isDefault) {
      await db.update(
        'shipping_addresses',
        {'is_default': 0},
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }

    // Cập nhật thông tin vào SQLite
    await db.update(
      'shipping_addresses',
      {
        'recipient_name': address.recipientName,
        'phone_number': address.phoneNumber,
        'province': address.province,
        'district': address.district,
        'ward': address.ward,
        'street_address': address.streetAddress,
        'label': address.label.name,
        'is_default': address.isDefault ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [address.id],
    );

    return address;
  }

  /// 4. XÓA ĐỊA CHỈ KHỎI SQLITE
  @override
  Future<void> deleteAddress(String addressId) async {
    final db = await appDatabase.database;
    await db.delete(
      'shipping_addresses',
      where: 'id = ?',
      whereArgs: [addressId],
    );
  }

  /// 5. ĐẶT ĐỊA CHỈ LÀM MẶC ĐỊNH
  @override
  Future<void> setDefaultAddress(String addressId) async {
    final db = await appDatabase.database;
    final userId = _getEffectiveUserId() ?? '1';

    // Hủy cờ mặc định toàn bộ
    await db.update(
      'shipping_addresses',
      {'is_default': 0},
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    // Bật cờ mặc định cho địa chỉ được chỉ định
    await db.update(
      'shipping_addresses',
      {'is_default': 1},
      where: 'id = ?',
      whereArgs: [addressId],
    );
  }
}
