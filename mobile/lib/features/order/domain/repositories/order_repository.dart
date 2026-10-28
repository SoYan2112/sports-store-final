import '../../../address/domain/entities/address_entity.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<OrderEntity> createOrder({
    required List<OrderItemEntity> items,
    required AddressEntity shippingAddress,
    required PaymentMethod paymentMethod,
    required ShippingMethod shippingMethod,
    required double subtotal,
    required double shippingFee,
    double discountAmount = 0,
    String? note,
  });

  Future<List<OrderEntity>> getOrders();
}

