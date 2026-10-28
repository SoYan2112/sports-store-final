import 'package:equatable/equatable.dart';

import '../../../address/domain/entities/address_entity.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

enum PaymentMethod {
  cod(
    code: 'COD',
    title: 'Thanh toán khi nhận hàng (COD)',
    subtitle: 'Thanh toán bằng tiền mặt khi nhận hàng',
  ),
  vnpay(
    code: 'VNPAY',
    title: 'VNPAY / Ngân hàng nội địa',
    subtitle: 'Thanh toán qua cổng VNPAY QR hoặc thẻ ATM',
  ),
  momo(
    code: 'MOMO',
    title: 'Ví điện tử MoMo',
    subtitle: 'Thanh toán nhanh qua ứng dụng MoMo',
  );

  final String code;
  final String title;
  final String subtitle;

  const PaymentMethod({
    required this.code,
    required this.title,
    required this.subtitle,
  });

  static PaymentMethod fromCode(String? code) {
    if (code == null) return PaymentMethod.cod;
    final upper = code.toUpperCase().trim();
    for (final method in PaymentMethod.values) {
      if (method.code == upper) return method;
    }
    return PaymentMethod.cod;
  }
}

enum ShippingMethod {
  standard(
    code: 'STANDARD',
    title: 'Giao hàng Tiêu chuẩn',
    estimatedTime: 'Nhận hàng trong 3 - 5 ngày',
    fee: 30000,
  ),
  express(
    code: 'EXPRESS',
    title: 'Giao hàng Hỏa tốc',
    estimatedTime: 'Nhận hàng trong 24h nội thành',
    fee: 55000,
  );

  final String code;
  final String title;
  final String estimatedTime;
  final double fee;

  const ShippingMethod({
    required this.code,
    required this.title,
    required this.estimatedTime,
    required this.fee,
  });

  static ShippingMethod fromCode(String? code) {
    if (code == null) return ShippingMethod.standard;
    final upper = code.toUpperCase().trim();
    for (final method in ShippingMethod.values) {
      if (method.code == upper) return method;
    }
    return ShippingMethod.standard;
  }
}

class OrderItemEntity extends Equatable {
  final String productId;
  final String name;
  final String brand;
  final double price;
  final String imageUrl;
  final String selectedSize;
  final int selectedColor;
  final int quantity;

  const OrderItemEntity({
    required this.productId,
    required this.name,
    required this.brand,
    required this.price,
    required this.imageUrl,
    required this.selectedSize,
    required this.selectedColor,
    required this.quantity,
  });

  double get totalPrice => price * quantity;

  factory OrderItemEntity.fromCartItem(CartItemEntity cartItem) {
    return OrderItemEntity(
      productId: cartItem.productId,
      name: cartItem.name,
      brand: cartItem.brand,
      price: cartItem.price,
      imageUrl: cartItem.imageUrl,
      selectedSize: cartItem.selectedSize,
      selectedColor: cartItem.selectedColor,
      quantity: cartItem.quantity,
    );
  }

  @override
  List<Object?> get props => [
        productId,
        name,
        brand,
        price,
        imageUrl,
        selectedSize,
        selectedColor,
        quantity,
      ];
}

class OrderEntity extends Equatable {
  final String id;
  final String? userId;
  final List<OrderItemEntity> items;
  final AddressEntity shippingAddress;
  final PaymentMethod paymentMethod;
  final ShippingMethod shippingMethod;
  final double subtotal;
  final double shippingFee;
  final double discountAmount;
  final double totalAmount;
  final String? note;
  final String status;
  final DateTime createdAt;

  const OrderEntity({
    required this.id,
    this.userId,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.shippingMethod,
    required this.subtotal,
    required this.shippingFee,
    this.discountAmount = 0,
    required this.totalAmount,
    this.note,
    this.status = 'Chờ xác nhận',
    required this.createdAt,
  });

  int get totalItemsCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        shippingAddress,
        paymentMethod,
        shippingMethod,
        subtotal,
        shippingFee,
        discountAmount,
        totalAmount,
        note,
        status,
        createdAt,
      ];
}

