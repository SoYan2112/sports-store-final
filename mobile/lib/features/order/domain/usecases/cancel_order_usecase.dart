import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class CancelOrderUseCase {
  final OrderRepository repository;

  CancelOrderUseCase(this.repository);

  // Gọi nghiệp vụ hủy đơn hàng
  Future<OrderEntity> call(String orderId, {String? reason}) {
    return repository.cancelOrder(orderId, reason: reason);
  }
}
