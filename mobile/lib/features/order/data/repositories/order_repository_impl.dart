import '../../../address/data/models/address_model.dart';
import '../../../address/domain/entities/address_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OrderEntity> createOrder({
    required List<OrderItemEntity> items,
    required AddressEntity shippingAddress,
    required PaymentMethod paymentMethod,
    required ShippingMethod shippingMethod,
    required double subtotal,
    required double shippingFee,
    double discountAmount = 0,
    String? note,
  }) async {
    final totalAmount =
        (subtotal + shippingFee - discountAmount).clamp(0.0, double.infinity);

    final payload = <String, dynamic>{
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
    };

    return await remoteDataSource.createOrder(payload);
  }

  @override
  Future<List<OrderEntity>> getOrders() async {
    return await remoteDataSource.getOrders();
  }
}

