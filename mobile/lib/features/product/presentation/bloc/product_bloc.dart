import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  static const int pageSize = 6;

  ProductBloc({required this.getProductsUseCase}) : super(const ProductInitial()) {
    on<FetchProductsEvent>(_onFetchProducts);
    on<FetchMoreProductsEvent>(_onFetchMoreProducts);
  }

  Future<void> _onFetchProducts(
    FetchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      final products = await getProductsUseCase(
        page: 1,
        size: pageSize,
        categoryId: event.categoryId,
        keyword: event.keyword,
      );

      emit(ProductLoaded(
        products: products,
        hasReachedMax: products.length < pageSize,
        currentPage: 1,
      ));
    } catch (e) {
      emit(ProductError(
        message: 'Không thể tải danh sách sản phẩm. Vui lòng thử lại sau.',
      ));
    }
  }

  Future<void> _onFetchMoreProducts(
    FetchMoreProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProductLoaded) return;
    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final moreProducts = await getProductsUseCase(
        page: nextPage,
        size: pageSize,
      );

      if (moreProducts.isEmpty) {
        emit(currentState.copyWith(
          hasReachedMax: true,
          isLoadingMore: false,
        ));
      } else {
        emit(ProductLoaded(
          products: [...currentState.products, ...moreProducts],
          hasReachedMax: moreProducts.length < pageSize,
          isLoadingMore: false,
          currentPage: nextPage,
        ));
      }
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }
}
