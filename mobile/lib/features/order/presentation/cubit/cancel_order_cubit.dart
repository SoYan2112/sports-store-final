import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/usecases/cancel_order_usecase.dart';
import 'cancel_order_state.dart';

// Quản lý hủy đơn (UC-20)
class CancelOrderCubit extends Cubit<CancelOrderState> {
  final CancelOrderUseCase cancelOrderUseCase;

  CancelOrderCubit({required this.cancelOrderUseCase})
      : super(const CancelOrderInitial());

  // Xử lý hủy đơn
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    // 1. Emit CancelOrderLoading()
    emit(const CancelOrderLoading());

    try {
      // 2. Gọi usecase gửi yêu cầu hủy
      await cancelOrderUseCase(orderId, reason: reason);

      // 3. Thành công -> emit CancelOrderSuccess()
      emit(CancelOrderSuccess(
        orderId: orderId,
        message: 'Đơn hàng #$orderId đã được hủy thành công',
      ));
    } on ServerException catch (e) {
      // 4. Lỗi server -> emit CancelOrderError()
      emit(CancelOrderError(e.message));
    } catch (e) {
      // 5. Lỗi khác -> emit CancelOrderError()
      var msg = e.toString()
          .replaceAll('ServerException:', '')
          .replaceAll('Exception:', '')
          .trim();
      emit(CancelOrderError(
        msg.isNotEmpty ? msg : 'Không thể hủy đơn hàng. Vui lòng thử lại sau.',
      ));
    }
  }

  // Reset trạng thái
  void reset() => emit(const CancelOrderInitial());
}
