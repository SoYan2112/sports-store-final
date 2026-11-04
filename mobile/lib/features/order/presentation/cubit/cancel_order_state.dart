import 'package:equatable/equatable.dart';

abstract class CancelOrderState extends Equatable {
  const CancelOrderState();

  @override
  List<Object?> get props => [];
}

class CancelOrderInitial extends CancelOrderState {
  const CancelOrderInitial();
}

class CancelOrderLoading extends CancelOrderState {
  const CancelOrderLoading();
}

class CancelOrderSuccess extends CancelOrderState {
  final String orderId;
  final String message;

  const CancelOrderSuccess({
    required this.orderId,
    this.message = 'Hủy đơn hàng thành công',
  });

  @override
  List<Object?> get props => [orderId, message];
}

class CancelOrderError extends CancelOrderState {
  final String message;

  const CancelOrderError(this.message);

  @override
  List<Object?> get props => [message];
}
