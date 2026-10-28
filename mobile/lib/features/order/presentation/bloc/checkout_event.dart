import 'package:equatable/equatable.dart';

import '../../../address/domain/entities/address_entity.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../domain/entities/order_entity.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

class LoadCheckoutDataEvent extends CheckoutEvent {
  const LoadCheckoutDataEvent();
}

class SelectShippingAddressEvent extends CheckoutEvent {
  final AddressEntity address;

  const SelectShippingAddressEvent(this.address);

  @override
  List<Object?> get props => [address];
}

class SelectPaymentMethodEvent extends CheckoutEvent {
  final PaymentMethod paymentMethod;

  const SelectPaymentMethodEvent(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

class SelectShippingMethodEvent extends CheckoutEvent {
  final ShippingMethod shippingMethod;

  const SelectShippingMethodEvent(this.shippingMethod);

  @override
  List<Object?> get props => [shippingMethod];
}

class PlaceOrderEvent extends CheckoutEvent {
  final List<CartItemEntity> items;
  final String? note;

  const PlaceOrderEvent({
    required this.items,
    this.note,
  });

  @override
  List<Object?> get props => [items, note];
}

