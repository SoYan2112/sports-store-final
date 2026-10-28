import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder(Map<String, dynamic> payload);
  Future<List<OrderModel>> getOrders();
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  static const String _ordersKeyPrefix = 'sports_store_orders_user_';
  static const String _guestOrdersKey = 'sports_store_orders_guest_v1';

  final Dio? dio;
  final SharedPreferences? sharedPreferences;
  final LocalStorageService? storageService;

  OrderRemoteDataSourceImpl({
    this.dio,
    this.sharedPreferences,
    this.storageService,
  });

  String _getStorageKey([String? userId]) {
    final effectiveUserId = userId ?? storageService?.getUserId();
    if (effectiveUserId != null && effectiveUserId.isNotEmpty) {
      return '$_ordersKeyPrefix$effectiveUserId';
    }
    return _guestOrdersKey;
  }

  @override
  Future<OrderModel> createOrder(Map<String, dynamic> payload) async {
    final userId = storageService?.getUserId();
    final now = DateTime.now();
    final generatedId =
        'SS${now.millisecondsSinceEpoch.toString().substring(7)}';

    final orderMap = <String, dynamic>{
      ...payload,
      'id': payload['id'] ?? generatedId,
      'userId': payload['userId'] ?? userId,
      'status': payload['status'] ?? 'Chờ xác nhận',
      'createdAt': payload['createdAt'] ?? now.toIso8601String(),
    };

    if (dio != null) {
      try {
        final response = await dio!.post('/orders', data: orderMap);
        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            final mapData = data['data'] is Map<String, dynamic>
                ? data['data'] as Map<String, dynamic>
                : data;
            final remoteOrder = OrderModel.fromJson({
              ...orderMap,
              ...mapData,
            });
            await _saveOrderToLocal(remoteOrder);
            return remoteOrder;
          }
        }
      } catch (_) {
        // Fallback lưu local khi backend chưa khởi chạy hoặc offline
      }
    }

    final localOrder = OrderModel.fromJson(orderMap);
    await _saveOrderToLocal(localOrder);
    return localOrder;
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    final prefs = sharedPreferences;
    if (prefs == null) return [];

    final key = _getStorageKey();
    final rawJson = prefs.getString(key);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveOrderToLocal(OrderModel order) async {
    final prefs = sharedPreferences;
    if (prefs == null) return;

    final currentOrders = await getOrders();
    final updated = [order, ...currentOrders];
    final key = _getStorageKey(order.userId);
    await prefs.setString(
      key,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }
}

