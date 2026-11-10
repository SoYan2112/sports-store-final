import '../../../../core/database/app_database.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../address/data/models/address_model.dart';
import '../../domain/entities/order_entity.dart';
import '../models/order_model.dart';
import 'order_remote_datasource.dart';

abstract class OrderLocalDataSource {
  Future<OrderModel> createOrder(Map<String, dynamic> payload);
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> cancelOrder(String orderId, {String? reason});
}

class OrderLocalDataSourceImpl
    implements OrderLocalDataSource, OrderRemoteDataSource {
  final AppDatabase appDatabase;
  final LocalStorageService? storageService;

  OrderLocalDataSourceImpl({
    AppDatabase? appDatabase,
    this.storageService,
  }) : appDatabase = appDatabase ?? AppDatabase.instance;

  String? _getEffectiveUserId() {
    return storageService?.getUserId();
  }

  @override
  Future<OrderModel> createOrder(Map<String, dynamic> payload) async {
    final db = await appDatabase.database;
    final userId = _getEffectiveUserId() ?? 'guest';
    final now = DateTime.now();
    final generatedId =
        payload['id']?.toString() ?? 'SS${now.millisecondsSinceEpoch.toString().substring(7)}';

    final rawAddress = payload['shippingAddress'] ?? payload['shipping_address'];
    final address = rawAddress is Map
        ? AddressModel.fromJson(Map<String, dynamic>.from(rawAddress))
        : (rawAddress is AddressModel
            ? rawAddress
            : const AddressModel(
                id: 'default',
                recipientName: '',
                phoneNumber: '',
                province: '',
                district: '',
                ward: '',
                streetAddress: '',
              ));

    final rawItems = payload['items'] as List<dynamic>? ?? [];
    final items = rawItems.map((e) {
      if (e is OrderItemModel) return e;
      if (e is OrderItemEntity) return OrderItemModel.fromEntity(e);
      return OrderItemModel.fromJson(Map<String, dynamic>.from(e as Map));
    }).toList();

    final subtotal = (payload['subtotal'] as num?)?.toDouble() ?? 0.0;
    final shippingFee = (payload['shippingFee'] as num?)?.toDouble() ??
        (payload['shipping_fee'] as num?)?.toDouble() ??
        30000.0;
    final discountAmount = (payload['discountAmount'] as num?)?.toDouble() ??
        (payload['discount_amount'] as num?)?.toDouble() ??
        0.0;
    final totalAmount = (payload['totalAmount'] as num?)?.toDouble() ??
        (payload['total_amount'] as num?)?.toDouble() ??
        (subtotal + shippingFee - discountAmount);

    final paymentMethodStr =
        payload['paymentMethod']?.toString() ?? payload['payment_method']?.toString() ?? 'COD';
    final shippingMethodStr =
        payload['shippingMethod']?.toString() ?? payload['shipping_method']?.toString() ?? 'STANDARD';

    await db.transaction((txn) async {
      // 1. Chèn đơn hàng vào bảng orders
      await txn.insert('orders', {
        'id': generatedId,
        'user_id': userId,
        'recipient_name': address.recipientName,
        'phone_number': address.phoneNumber,
        'province': address.province,
        'district': address.district,
        'ward': address.ward,
        'street_address': address.streetAddress,
        'payment_method': paymentMethodStr,
        'shipping_method': shippingMethodStr,
        'subtotal': subtotal,
        'shipping_fee': shippingFee,
        'discount_amount': discountAmount,
        'total_amount': totalAmount,
        'note': payload['note'] as String?,
        'status': 'Chờ xác nhận',
        'created_at': now.toIso8601String(),
      });

      // 2. Chèn từng item vào bảng order_items
      for (final it in items) {
        await txn.insert('order_items', {
          'order_id': generatedId,
          'product_id': it.productId,
          'name': it.name,
          'brand': it.brand,
          'price': it.price,
          'image_url': it.imageUrl,
          'selected_size': it.selectedSize,
          'selected_color': it.selectedColor,
          'quantity': it.quantity,
        });

        // 3. Giảm tồn kho sản phẩm trong bảng products
        await txn.rawUpdate(
          'UPDATE products SET stock = MAX(0, stock - ?) WHERE id = ?',
          [it.quantity, it.productId],
        );
      }
    });

    return OrderModel(
      id: generatedId,
      userId: userId,
      items: items,
      shippingAddress: address,
      paymentMethod: PaymentMethod.fromCode(paymentMethodStr),
      shippingMethod: ShippingMethod.fromCode(shippingMethodStr),
      subtotal: subtotal,
      shippingFee: shippingFee,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      note: payload['note'] as String?,
      status: 'Chờ xác nhận',
      createdAt: now,
    );
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    final db = await appDatabase.database;
    final userId = _getEffectiveUserId();

    final List<Map<String, dynamic>> orderRows;
    if (userId != null && userId.isNotEmpty) {
      orderRows = await db.query(
        'orders',
        where: 'user_id = ? OR user_id = ?',
        whereArgs: [userId, 'guest'],
        orderBy: 'created_at DESC',
      );
    } else {
      orderRows = await db.query(
        'orders',
        orderBy: 'created_at DESC',
      );
    }

    final List<OrderModel> orders = [];
    for (final row in orderRows) {
      final orderId = row['id'] as String;

      // Lấy danh sách items tương ứng từ order_items
      final itemRows = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );

      final items = itemRows.map((it) {
        return OrderItemModel(
          productId: it['product_id'] as String,
          name: it['name'] as String,
          brand: it['brand'] as String? ?? '',
          price: (it['price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: it['image_url'] as String? ?? '',
          selectedSize: it['selected_size'] as String? ?? '',
          selectedColor: (it['selected_color'] as num?)?.toInt() ?? 0xFF1A1A1A,
          quantity: (it['quantity'] as num?)?.toInt() ?? 1,
        );
      }).toList();

      final address = AddressModel(
        id: 'addr_$orderId',
        recipientName: row['recipient_name'] as String? ?? '',
        phoneNumber: row['phone_number'] as String? ?? '',
        province: row['province'] as String? ?? '',
        district: row['district'] as String? ?? '',
        ward: row['ward'] as String? ?? '',
        streetAddress: row['street_address'] as String? ?? '',
      );

      orders.add(OrderModel(
        id: orderId,
        userId: row['user_id'] as String?,
        items: items,
        shippingAddress: address,
        paymentMethod: PaymentMethod.fromCode(row['payment_method']?.toString()),
        shippingMethod: ShippingMethod.fromCode(row['shipping_method']?.toString()),
        subtotal: (row['subtotal'] as num?)?.toDouble() ?? 0.0,
        shippingFee: (row['shipping_fee'] as num?)?.toDouble() ?? 30000.0,
        discountAmount: (row['discount_amount'] as num?)?.toDouble() ?? 0.0,
        totalAmount: (row['total_amount'] as num?)?.toDouble() ?? 0.0,
        note: row['note'] as String?,
        status: row['status'] as String? ?? 'Chờ xác nhận',
        createdAt: DateTime.tryParse(row['created_at'].toString()) ?? DateTime.now(),
      ));
    }

    return orders;
  }

  @override
  Future<OrderModel> cancelOrder(String orderId, {String? reason}) async {
    final db = await appDatabase.database;

    final existing = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [orderId],
    );

    if (existing.isEmpty) {
      throw ServerException(message: 'Không tìm thấy đơn hàng mã $orderId');
    }

    final reasonText = reason != null && reason.trim().isNotEmpty
        ? ' [Lý do: $reason]'
        : '';

    await db.update(
      'orders',
      {
        'status': 'Đã hủy',
        'note': (existing.first['note'] as String? ?? '') + reasonText,
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );

    final orders = await getOrders();
    return orders.firstWhere((o) => o.id == orderId);
  }
}
