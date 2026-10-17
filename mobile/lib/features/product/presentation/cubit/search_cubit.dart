import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final GetProductsUseCase getProductsUseCase;

  SearchCubit({required this.getProductsUseCase})
      : super(const SearchInitial());

  Future<void> search(String keyword) async {
    final query = keyword.trim();
    if (query.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(const SearchLoading());

    try {
      final products = await getProductsUseCase(
        page: 1,
        size: 50,
        keyword: query,
      );

      if (products.isEmpty) {
        emit(SearchEmpty(query));
      } else {
        emit(SearchLoaded(products));
      }
    } catch (e) {
      emit(const SearchError('Đã xảy ra lỗi khi tìm kiếm sản phẩm.'));
    }
  }

  void clear() {
    emit(const SearchInitial());
  }
}
