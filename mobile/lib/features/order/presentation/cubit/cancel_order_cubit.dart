import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/usecases/cancel_order_usecase.dart';
import 'cancel_order_state.dart';

class CancelOrderCubit extends Cubit<CancelOrderState> {
  final CancelOrderUseCase cancelOrderUseCase;

  CancelOrderCubit({required this.cancelOrderUseCase})
      : super(const CancelOrderInitial());

  // Xử lý hủy đơn hàng
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    emit(const CancelOrderLoading());

    try {
      await cancelOrderUseCase(orderId, reason: reason);
      emit(CancelOrderSuccess(
        orderId: orderId,
        message: 'Đơn hàng #$orderId đã được hủy thành công',
      ));
    } on ServerException catch (e) {
      emit(CancelOrderError(e.message));
    } catch (e) {
      var msg = e.toString()
          .replaceAll('ServerException:', '')
          .replaceAll('Exception:', '')
          .trim();
      emit(CancelOrderError(
        msg.isNotEmpty ? msg : 'Không thể hủy đơn hàng. Vui lòng thử lại sau.',
      ));
    }
  }

  void reset() => emit(const CancelOrderInitial());
}
