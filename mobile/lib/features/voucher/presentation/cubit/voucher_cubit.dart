import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_vouchers_usecase.dart';
import 'voucher_state.dart';

// Quản lý trạng thái danh sách mã ưu đãi & voucher (UC-21)
class VoucherCubit extends Cubit<VoucherState> {
  final GetVouchersUseCase getVouchersUseCase;

  VoucherCubit({required this.getVouchersUseCase})
      : super(const VoucherInitial());

  // Hàm tải danh sách voucher từ UseCase (CSDL SQLite / API)
  Future<void> fetchVouchers() async {
    // 1. Phát ra trạng thái đang tải (Loading) để hiển thị Shimmer/Spinner
    emit(const VoucherLoading());
    try {
      // 2. Gọi UseCase lấy danh sách voucher khả dụng
      final vouchers = await getVouchersUseCase();
      // 3. Phát ra trạng thái nạp thành công (Loaded) kèm danh sách voucher để UI hiển thị
      emit(VoucherLoaded(vouchers: vouchers));
    } catch (e) {
      // 4. Bắt ngoại lệ và phát ra thông báo lỗi (Error)
      emit(const VoucherError(
        message: 'Không thể tải danh sách voucher ưu đãi. Vui lòng thử lại.',
      ));
    }
  }
}

