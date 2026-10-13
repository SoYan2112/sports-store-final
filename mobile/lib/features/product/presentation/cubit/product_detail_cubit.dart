import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_product_detail_usecase.dart';
import 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  final GetProductDetailUseCase getProductDetailUseCase;

  ProductDetailCubit({required this.getProductDetailUseCase})
      : super(const ProductDetailInitial());

  Future<void> loadProduct(String id, {ProductEntity? initialProduct}) async {
    if (initialProduct != null) {
      emit(ProductDetailLoaded(product: initialProduct));
    } else {
      emit(const ProductDetailLoading());
    }

    try {
      final product = await getProductDetailUseCase(id);
      final currentQty = (state is ProductDetailLoaded)
          ? (state as ProductDetailLoaded).quantity
          : 1;

      emit(ProductDetailLoaded(
        product: product,
        quantity: currentQty,
      ));
    } catch (e) {
      if (state is! ProductDetailLoaded) {
        emit(const ProductDetailError(
          message: 'Không thể tải thông tin chi tiết sản phẩm. Vui lòng thử lại.',
        ));
      }
    }
  }

  void incrementQuantity() {
    if (state is ProductDetailLoaded) {
      final current = state as ProductDetailLoaded;
      if (current.quantity < current.product.stock) {
        emit(current.copyWith(quantity: current.quantity + 1));
      }
    }
  }

  void decrementQuantity() {
    if (state is ProductDetailLoaded) {
      final current = state as ProductDetailLoaded;
      if (current.quantity > 1) {
        emit(current.copyWith(quantity: current.quantity - 1));
      }
    }
  }

  void selectSize(String size) {
    if (state is ProductDetailLoaded) {
      final current = state as ProductDetailLoaded;
      if (current.outOfStockSizes.contains(size)) return;
      emit(current.copyWith(selectedSize: size));
    }
  }

  void selectColor(int color) {
    if (state is ProductDetailLoaded) {
      final current = state as ProductDetailLoaded;
      emit(current.copyWith(selectedColor: color));
    }
  }
}
