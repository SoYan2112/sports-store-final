import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'search_state.dart';

// Quản lý tìm kiếm (UC-09)
class SearchCubit extends Cubit<SearchState> {
  final GetProductsUseCase getProductsUseCase;

  SearchCubit({required this.getProductsUseCase})
      : super(const SearchInitial());

  // Tìm kiếm theo từ khóa
  Future<void> search(String keyword) async {
    // 1. Cắt khoảng trắng
    final query = keyword.trim();

    // 2. Rỗng -> emit SearchInitial()
    if (query.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    // 3. Emit SearchLoading()
    emit(const SearchLoading());

    try {
      // 4. Gọi usecase lấy danh sách theo từ khóa
      final products = await getProductsUseCase(
        page: 1,
        size: 50,
        keyword: query,
      );

      // 5. Kết quả: rỗng -> SearchEmpty(), có -> SearchLoaded()
      if (products.isEmpty) {
        emit(SearchEmpty(query));
      } else {
        emit(SearchLoaded(products));
      }
    } catch (e) {
      // 6. Lỗi -> emit SearchError()
      emit(const SearchError('Đã xảy ra lỗi khi tìm kiếm sản phẩm.'));
    }
  }

  // Xóa tìm kiếm
  void clear() {
    emit(const SearchInitial());
  }
}
