import 'package:equatable/equatable.dart';

import '../../../address/domain/entities/address_entity.dart';
import '../../../voucher/domain/entities/voucher_entity.dart';
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
  final VoucherEntity? appliedVoucher;
  final double discountAmount;

  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.selectedAddress,
    this.paymentMethod = PaymentMethod.cod,
    this.shippingMethod = ShippingMethod.standard,
    this.createdOrder,
    this.errorMessage,
    this.appliedVoucher,
    this.discountAmount = 0.0,
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
    VoucherEntity? appliedVoucher,
    bool clearVoucher = false,
    double? discountAmount,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      createdOrder: createdOrder ?? this.createdOrder,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      appliedVoucher:
          clearVoucher ? null : (appliedVoucher ?? this.appliedVoucher),
      discountAmount:
          clearVoucher ? 0.0 : (discountAmount ?? this.discountAmount),
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
        appliedVoucher,
        discountAmount,
      ];
}
