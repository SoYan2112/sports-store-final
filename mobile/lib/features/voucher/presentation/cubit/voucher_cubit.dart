import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_vouchers_usecase.dart';
import 'voucher_state.dart';

class VoucherCubit extends Cubit<VoucherState> {
  final GetVouchersUseCase getVouchersUseCase;

  VoucherCubit({required this.getVouchersUseCase})
      : super(const VoucherInitial());

  Future<void> fetchVouchers() async {
    emit(const VoucherLoading());
    try {
      final vouchers = await getVouchersUseCase();
      emit(VoucherLoaded(vouchers: vouchers));
    } catch (e) {
      emit(const VoucherError(
        message: 'Không thể tải danh sách voucher ưu đãi. Vui lòng thử lại.',
      ));
    }
  }
}

