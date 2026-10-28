import 'package:equatable/equatable.dart';

import '../../../address/domain/entities/address_entity.dart';
import '../../domain/entities/order_entity.dart';

enum CheckoutStatus {
  initial,
  loadingAddress,
  ready,
  submitting,
  success,
  failure,
}

class CheckoutState extends Equatable {
  final CheckoutStatus status;
  final AddressEntity? selectedAddress;
  final PaymentMethod paymentMethod;
  final ShippingMethod shippingMethod;
  final OrderEntity? createdOrder;
  final String? errorMessage;

  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.selectedAddress,
    this.paymentMethod = PaymentMethod.cod,
    this.shippingMethod = ShippingMethod.standard,
    this.createdOrder,
    this.errorMessage,
  });

  bool get isSubmitting => status == CheckoutStatus.submitting;
  bool get isLoadingAddress => status == CheckoutStatus.loadingAddress;

  CheckoutState copyWith({
    CheckoutStatus? status,
    AddressEntity? selectedAddress,
    PaymentMethod? paymentMethod,
    ShippingMethod? shippingMethod,
    OrderEntity? createdOrder,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      createdOrder: createdOrder ?? this.createdOrder,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedAddress,
        paymentMethod,
        shippingMethod,
        createdOrder,
        errorMessage,
      ];
}

