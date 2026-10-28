import 'package:equatable/equatable.dart';

import '../../../address/domain/entities/address_entity.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class CreateOrderParams extends Equatable {
  final List<OrderItemEntity> items;
  final AddressEntity shippingAddress;
  final PaymentMethod paymentMethod;
  final ShippingMethod shippingMethod;
  final double subtotal;
  final double shippingFee;
  final double discountAmount;
  final String? note;

  const CreateOrderParams({
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.shippingMethod,
    required this.subtotal,
    required this.shippingFee,
    this.discountAmount = 0,
    this.note,
  });

  double get totalAmount => subtotal + shippingFee - discountAmount;

  @override
  List<Object?> get props => [
        items,
        shippingAddress,
        paymentMethod,
        shippingMethod,
        subtotal,
        shippingFee,
        discountAmount,
        note,
      ];
}

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  Future<OrderEntity> call(CreateOrderParams params) async {
    return await repository.createOrder(
      items: params.items,
      shippingAddress: params.shippingAddress,
      paymentMethod: params.paymentMethod,
      shippingMethod: params.shippingMethod,
      subtotal: params.subtotal,
      shippingFee: params.shippingFee,
      discountAmount: params.discountAmount,
      note: params.note,
    );
  }
}

