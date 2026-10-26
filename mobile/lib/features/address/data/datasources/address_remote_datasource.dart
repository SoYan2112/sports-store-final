import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/address_model.dart';
import '../../domain/entities/address_entity.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> addAddress(AddressModel address);
  Future<AddressModel> updateAddress(AddressModel address);
  Future<void> deleteAddress(String addressId);
  Future<void> setDefaultAddress(String addressId);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  static const String _storageKey = 'sports_store_shipping_addresses_v1';

  final Dio dio;
  final SharedPreferences sharedPreferences;

  AddressRemoteDataSourceImpl({
    required this.dio,
    required this.sharedPreferences,
  });

  @override
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await dio.get(ApiEndpoints.addresses);
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data is Map<String, dynamic>
            ? (data['data'] as List<dynamic>? ?? data['items'] as List<dynamic>? ?? [])
            : (data as List<dynamic>? ?? []);
        final list = items
            .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
            .toList();
        await _saveToLocal(list);
        return list;
      } else {
        throw ServerException(
          message: 'Lỗi máy chủ khi lấy danh sách địa chỉ: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException {
      // Khi backend chưa sẵn sàng, lấy từ SharedPreferences hoặc dữ liệu mẫu
      return _getLocalAddresses();
    } catch (e) {
      if (e is ServerException) rethrow;
      return _getLocalAddresses();
    }
  }

  @override
  Future<AddressModel> addAddress(AddressModel address) async {
    try {
      final response = await dio.post(
        ApiEndpoints.addresses,
        data: address.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final json = data is Map<String, dynamic> && data.containsKey('data')
            ? data['data'] as Map<String, dynamic>
            : data as Map<String, dynamic>;
        final created = AddressModel.fromJson(json);
        await _syncAddLocal(created);
        return created;
      }
    } on DioException {
      // Khi backend chưa sẵn sàng, lưu trực tiếp vào local storage
    } catch (_) {
      // Bỏ qua lỗi mạng và tiếp tục lưu offline
    }

    // Gán ID duy nhất nếu chưa có
    final resolvedAddress = address.id.isEmpty
        ? AddressModel(
            id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
            recipientName: address.recipientName,
            phoneNumber: address.phoneNumber,
            province: address.province,
            district: address.district,
            ward: address.ward,
            streetAddress: address.streetAddress,
            label: address.label,
            isDefault: address.isDefault,
          )
        : address;

    await _syncAddLocal(resolvedAddress);
    return resolvedAddress;
  }

  @override
  Future<AddressModel> updateAddress(AddressModel address) async {
    final list = _getLocalAddresses();
    final index = list.indexWhere((a) => a.id == address.id);
    if (index != -1) {
      var updatedList = List<AddressModel>.from(list);
      if (address.isDefault) {
        updatedList = updatedList
            .map((a) => a.copyWith(isDefault: a.id == address.id))
            .map((e) => AddressModel.fromEntity(e))
            .toList();
      }
      updatedList[index] = address;
      await _saveToLocal(updatedList);
    }
    return address;
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    final list = _getLocalAddresses();
    final updatedList = list.where((a) => a.id != addressId).toList();
    if (updatedList.isNotEmpty && !updatedList.any((a) => a.isDefault)) {
      // Nếu xóa địa chỉ mặc định, tự động gán địa chỉ đầu tiên làm mặc định
      final first = updatedList.first;
      updatedList[0] = AddressModel.fromEntity(first.copyWith(isDefault: true));
    }
    await _saveToLocal(updatedList);
  }

  @override
  Future<void> setDefaultAddress(String addressId) async {
    final list = _getLocalAddresses();
    final updatedList = list.map((a) {
      final isDef = a.id == addressId;
      return AddressModel.fromEntity(a.copyWith(isDefault: isDef));
    }).toList();
    await _saveToLocal(updatedList);
  }

  // --- Hỗ trợ lưu trữ SharedPreferences ---

  List<AddressModel> _getLocalAddresses() {
    final rawJson = sharedPreferences.getString(_storageKey);
    if (rawJson != null && rawJson.trim().isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
        return decoded
            .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    // Địa chỉ mẫu ban đầu chuẩn thông tin Việt Nam
    final initialList = [
      const AddressModel(
        id: 'addr_sample_01',
        recipientName: 'Trần Hoàng Nhật',
        phoneNumber: '0905123456',
        province: 'TP. Hồ Chí Minh',
        district: 'Quận 1',
        ward: 'Phường Bến Nghé',
        streetAddress: '123 Đường Lê Duẩn',
        label: AddressLabel.home,
        isDefault: true,
      ),
      const AddressModel(
        id: 'addr_sample_02',
        recipientName: 'Trần Hoàng Nhật',
        phoneNumber: '0905123456',
        province: 'TP. Hồ Chí Minh',
        district: 'Quận 7',
        ward: 'Phường Tân Phong',
        streetAddress: 'Tòa nhà văn phòng Cobi Tower, Đường Hoàng Văn Thái',
        label: AddressLabel.office,
        isDefault: false,
      ),
    ];

    _saveToLocal(initialList);
    return initialList;
  }

  Future<void> _syncAddLocal(AddressModel newAddress) async {
    final list = _getLocalAddresses();
    var updatedList = List<AddressModel>.from(list);

    if (newAddress.isDefault || updatedList.isEmpty) {
      // Nếu địa chỉ mới là mặc định hoặc danh sách đang rỗng, bỏ mặc định của các địa chỉ cũ
      updatedList = updatedList
          .map((a) => AddressModel.fromEntity(a.copyWith(isDefault: false)))
          .toList();
      final forcedDefault = newAddress.copyWith(isDefault: true);
      updatedList.insert(0, AddressModel.fromEntity(forcedDefault));
    } else {
      updatedList.add(newAddress);
    }

    await _saveToLocal(updatedList);
  }

  Future<void> _saveToLocal(List<AddressModel> list) async {
    final raw = jsonEncode(list.map((e) => e.toJson()).toList());
    await sharedPreferences.setString(_storageKey, raw);
  }
}
