import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCartItems({String? userId});
  Future<void> saveCartItems(List<CartItemModel> items, {String? userId});
  Future<void> clearCart({String? userId});
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  static const String _legacyKey = 'sports_store_cart_items_v1';
  static const String _userKeyPrefix = 'sports_store_cart_items_user_';

  final SharedPreferences sharedPreferences;
  final LocalStorageService? storageService;

  CartLocalDataSourceImpl({
    required this.sharedPreferences,
    this.storageService,
  });

  String _getStorageKey([String? userId]) {
    final effectiveUserId = userId ?? storageService?.getUserId();
    if (effectiveUserId != null && effectiveUserId.isNotEmpty) {
      return '$_userKeyPrefix$effectiveUserId';
    }
    return _legacyKey;
  }

  @override
  Future<List<CartItemModel>> getCartItems({String? userId}) async {
    if (storageService != null) {
      final effectiveUserId = userId ?? storageService?.getUserId();
      if (effectiveUserId == null || effectiveUserId.isEmpty) {
        return [];
      }
    }

    final key = _getStorageKey(userId);
    final rawJson = sharedPreferences.getString(key);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveCartItems(List<CartItemModel> items, {String? userId}) async {
    final key = _getStorageKey(userId);
    final jsonList = items.map((i) => i.toJson()).toList();
    await sharedPreferences.setString(key, jsonEncode(jsonList));
  }

  @override
  Future<void> clearCart({String? userId}) async {
    final key = _getStorageKey(userId);
    await sharedPreferences.remove(key);
  }
}
