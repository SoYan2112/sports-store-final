import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../address/domain/entities/address_entity.dart';
import '../../../address/domain/usecases/get_addresses_usecase.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/create_order_usecase.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CreateOrderUseCase createOrderUseCase;
  final GetAddressesUseCase? getAddressesUseCase;

  CheckoutBloc({
    required this.createOrderUseCase,
    this.getAddressesUseCase,
  }) : super(const CheckoutState()) {
    on<LoadCheckoutDataEvent>(_onLoadCheckoutData);
    on<SelectShippingAddressEvent>(_onSelectShippingAddress);
    on<SelectPaymentMethodEvent>(_onSelectPaymentMethod);
    on<SelectShippingMethodEvent>(_onSelectShippingMethod);
    on<PlaceOrderEvent>(_onPlaceOrder);
  }

  Future<void> _onLoadCheckoutData(
    LoadCheckoutDataEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(status: CheckoutStatus.loadingAddress, clearError: true));
    try {
      AddressEntity? defaultAddress;
      if (getAddressesUseCase != null) {
        final addresses = await getAddressesUseCase!();
        if (addresses.isNotEmpty) {
          defaultAddress = addresses.firstWhere(
            (addr) => addr.isDefault,
            orElse: () => addresses.first,
          );
        }
      }
      emit(state.copyWith(
        status: CheckoutStatus.ready,
        selectedAddress: defaultAddress,
        clearError: true,
      ));
    } catch (_) {
      emit(state.copyWith(status: CheckoutStatus.ready, clearError: true));
    }
  }

  void _onSelectShippingAddress(
    SelectShippingAddressEvent event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(
      status: CheckoutStatus.ready,
      selectedAddress: event.address,
      clearError: true,
    ));
  }

  void _onSelectPaymentMethod(
    SelectPaymentMethodEvent event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(
      status: CheckoutStatus.ready,
      paymentMethod: event.paymentMethod,
      clearError: true,
    ));
  }

  void _onSelectShippingMethod(
    SelectShippingMethodEvent event,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(
      status: CheckoutStatus.ready,
      shippingMethod: event.shippingMethod,
      clearError: true,
    ));
  }

  Future<void> _onPlaceOrder(
    PlaceOrderEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    if (event.items.isEmpty) {
      emit(state.copyWith(
        status: CheckoutStatus.failure,
        errorMessage: 'Giỏ hàng trống, không thể đặt hàng.',
      ));
      return;
    }

    final shippingAddress = state.selectedAddress;
    if (shippingAddress == null) {
      emit(state.copyWith(
        status: CheckoutStatus.failure,
        errorMessage: 'Vui lòng chọn địa chỉ nhận hàng trước khi đặt hàng.',
      ));
      return;
    }

    emit(state.copyWith(status: CheckoutStatus.submitting, clearError: true));

    try {
      final orderItems = event.items
          .map((cartItem) => OrderItemEntity.fromCartItem(cartItem))
          .toList();

      final subtotal = event.items.fold<double>(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );

      final order = await createOrderUseCase(
        CreateOrderParams(
          items: orderItems,
          shippingAddress: shippingAddress,
          paymentMethod: state.paymentMethod,
          shippingMethod: state.shippingMethod,
          subtotal: subtotal,
          shippingFee: state.shippingMethod.fee,
          note: event.note?.trim().isEmpty == true ? null : event.note?.trim(),
        ),
      );

      emit(state.copyWith(
        status: CheckoutStatus.success,
        createdOrder: order,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CheckoutStatus.failure,
        errorMessage: 'Đặt hàng thất bại: ${e.toString()}',
      ));
    }
  }
}

