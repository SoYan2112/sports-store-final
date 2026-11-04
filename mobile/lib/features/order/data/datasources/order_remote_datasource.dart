import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../address/data/models/address_model.dart';
import '../../domain/entities/order_entity.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder(Map<String, dynamic> payload);
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> cancelOrder(String orderId, {String? reason});
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

  @override
  Future<OrderModel> cancelOrder(String orderId, {String? reason}) async {
    if (dio != null) {
      try {
        final response = await dio!.post(
          '/orders/$orderId/cancel',
          data: {'reason': reason ?? 'Người dùng yêu cầu hủy đơn'},
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            final mapData = data['data'] is Map<String, dynamic>
                ? data['data'] as Map<String, dynamic>
                : data;
            final remoteOrder = OrderModel.fromJson(mapData);
            await _updateOrderInLocal(remoteOrder);
            return remoteOrder;
          }
        }
      } catch (_) {}
    }

    final currentOrders = await getOrders();
    final index = currentOrders.indexWhere((o) => o.id == orderId);

    if (index == -1) {
      final demoStatuses = {
        'SS000123': 'Chờ xác nhận',
        'SS000122': 'Đang giao',
        'SS000118': 'Đã giao',
      };

      final demoStatus = demoStatuses[orderId] ?? 'Chờ xác nhận';
      final isDemoPending = demoStatus.toLowerCase().contains('chờ') ||
          demoStatus.toLowerCase().contains('pending');

      if (!isDemoPending) {
        if (demoStatus.toLowerCase().contains('đang')) {
          throw const ServerException(
            message: 'Đơn hàng đang trong quá trình giao, không thể hủy.',
          );
        }
        throw const ServerException(
          message: 'Đơn hàng đã được giao hoặc hoàn tất, không thể hủy.',
        );
      }

      final now = DateTime.now();
      final cancelled = OrderModel(
        id: orderId,
        items: const [],
        shippingAddress: const AddressModel(
          id: 'default',
          recipientName: '',
          phoneNumber: '',
          province: '',
          district: '',
          ward: '',
          streetAddress: '',
        ),
        paymentMethod: PaymentMethod.cod,
        shippingMethod: ShippingMethod.standard,
        subtotal: 0,
        shippingFee: 0,
        totalAmount: 0,
        note: reason != null ? 'Lý do hủy: $reason' : null,
        status: 'Đã hủy',
        createdAt: now,
      );
      await _saveOrderToLocal(cancelled);
      return cancelled;
    }

    final order = currentOrders[index];

    // Chỉ cho phép hủy khi đơn ở trạng thái 'Chờ xác nhận'
    final normalizedStatus = order.status.toLowerCase();
    final isPending = normalizedStatus.contains('chờ') ||
        normalizedStatus.contains('pending');

    if (!isPending) {
      if (normalizedStatus.contains('hủy') || normalizedStatus.contains('cancel')) {
        throw const ServerException(
          message: 'Đơn hàng này đã được hủy trước đó.',
        );
      }
      if (normalizedStatus.contains('đang')) {
        throw const ServerException(
          message: 'Đơn hàng đang trong quá trình giao, không thể hủy.',
        );
      }
      throw const ServerException(
        message: 'Đơn hàng đã hoàn thành hoặc đang giao, không thể hủy.',
      );
    }

    final updatedOrder = OrderModel(
      id: order.id,
      userId: order.userId,
      items: order.items,
      shippingAddress: order.shippingAddress,
      paymentMethod: order.paymentMethod,
      shippingMethod: order.shippingMethod,
      subtotal: order.subtotal,
      shippingFee: order.shippingFee,
      discountAmount: order.discountAmount,
      totalAmount: order.totalAmount,
      note: reason != null
          ? '${order.note ?? ""}\nLý do hủy: $reason'.trim()
          : order.note,
      status: 'Đã hủy',
      createdAt: order.createdAt,
    );

    currentOrders[index] = updatedOrder;
    await _saveAllOrdersToLocal(currentOrders, order.userId);
    return updatedOrder;
  }

  Future<void> _updateOrderInLocal(OrderModel order) async {
    final currentOrders = await getOrders();
    final index = currentOrders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      currentOrders[index] = order;
      await _saveAllOrdersToLocal(currentOrders, order.userId);
    } else {
      await _saveOrderToLocal(order);
    }
  }

  Future<void> _saveAllOrdersToLocal(
    List<OrderModel> orders, [
    String? userId,
  ]) async {
    final prefs = sharedPreferences;
    if (prefs == null) return;
    final key = _getStorageKey(userId);
    await prefs.setString(
      key,
      jsonEncode(orders.map((e) => e.toJson()).toList()),
    );
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
