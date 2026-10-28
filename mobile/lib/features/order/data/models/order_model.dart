import '../../../address/data/models/address_model.dart';
import '../../domain/entities/order_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.productId,
    required super.name,
    required super.brand,
    required super.price,
    required super.imageUrl,
    required super.selectedSize,
    required super.selectedColor,
    required super.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId']?.toString() ?? json['product_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? '',
      selectedSize: json['selectedSize']?.toString() ?? json['size']?.toString() ?? '',
      selectedColor: (json['selectedColor'] as num?)?.toInt() ??
          (json['color'] as num?)?.toInt() ??
          0xFF1A1A1A,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'brand': brand,
      'price': price,
      'imageUrl': imageUrl,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'quantity': quantity,
    };
  }

  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      productId: entity.productId,
      name: entity.name,
      brand: entity.brand,
      price: entity.price,
      imageUrl: entity.imageUrl,
      selectedSize: entity.selectedSize,
      selectedColor: entity.selectedColor,
      quantity: entity.quantity,
    );
  }
}

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    super.userId,
    required super.items,
    required super.shippingAddress,
    required super.paymentMethod,
    required super.shippingMethod,
    required super.subtotal,
    required super.shippingFee,
    super.discountAmount = 0,
    required super.totalAmount,
    super.note,
    super.status = 'Chờ xác nhận',
    required super.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((e) => OrderItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final rawAddress = json['shippingAddress'] ?? json['shipping_address'];
    final address = rawAddress is Map
        ? AddressModel.fromJson(Map<String, dynamic>.from(rawAddress))
        : const AddressModel(
            id: 'default',
            recipientName: '',
            phoneNumber: '',
            province: '',
            district: '',
            ward: '',
            streetAddress: '',
          );

    final subtotal = (json['subtotal'] as num?)?.toDouble() ?? 0.0;
    final shippingFee = (json['shippingFee'] as num?)?.toDouble() ??
        (json['shipping_fee'] as num?)?.toDouble() ??
        30000.0;
    final discountAmount = (json['discountAmount'] as num?)?.toDouble() ??
        (json['discount_amount'] as num?)?.toDouble() ??
        0.0;
    final totalAmount = (json['totalAmount'] as num?)?.toDouble() ??
        (json['total_amount'] as num?)?.toDouble() ??
        (subtotal + shippingFee - discountAmount);

    final createdAtStr =
        json['createdAt']?.toString() ?? json['created_at']?.toString();

    return OrderModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      items: items,
      shippingAddress: address,
      paymentMethod: PaymentMethod.fromCode(
        json['paymentMethod']?.toString() ?? json['payment_method']?.toString(),
      ),
      shippingMethod: ShippingMethod.fromCode(
        json['shippingMethod']?.toString() ?? json['shipping_method']?.toString(),
      ),
      subtotal: subtotal,
      shippingFee: shippingFee,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      note: json['note']?.toString(),
      status: json['status']?.toString() ?? 'Chờ xác nhận',
      createdAt: createdAtStr != null
          ? (DateTime.tryParse(createdAtStr) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items
          .map((item) => OrderItemModel.fromEntity(item).toJson())
          .toList(),
      'shippingAddress': AddressModel.fromEntity(shippingAddress).toJson(),
      'paymentMethod': paymentMethod.code,
      'shippingMethod': shippingMethod.code,
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'note': note,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      userId: entity.userId,
      items: entity.items,
      shippingAddress: entity.shippingAddress,
      paymentMethod: entity.paymentMethod,
      shippingMethod: entity.shippingMethod,
      subtotal: entity.subtotal,
      shippingFee: entity.shippingFee,
      discountAmount: entity.discountAmount,
      totalAmount: entity.totalAmount,
      note: entity.note,
      status: entity.status,
      createdAt: entity.createdAt,
    );
  }
}

