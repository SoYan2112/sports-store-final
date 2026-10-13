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
      emit(ProductDetailLoaded(
        product: initialProduct,
        selectedSize: initialProduct.sizes.isNotEmpty ? initialProduct.sizes.first : null,
        selectedColor: initialProduct.colors.isNotEmpty ? initialProduct.colors.first : null,
      ));
    } else {
      emit(const ProductDetailLoading());
    }

    try {
      final product = await getProductDetailUseCase(id);
      final currentSize = (state is ProductDetailLoaded)
          ? (state as ProductDetailLoaded).selectedSize
          : null;
      final currentColor = (state is ProductDetailLoaded)
          ? (state as ProductDetailLoaded).selectedColor
          : null;
      final currentQty = (state is ProductDetailLoaded)
          ? (state as ProductDetailLoaded).quantity
          : 1;
      final currentFav = (state is ProductDetailLoaded)
          ? (state as ProductDetailLoaded).isFavorite
          : false;

      emit(ProductDetailLoaded(
        product: product,
        selectedSize: currentSize ?? (product.sizes.isNotEmpty ? product.sizes.first : null),
        selectedColor: currentColor ?? (product.colors.isNotEmpty ? product.colors.first : null),
        quantity: currentQty,
        isFavorite: currentFav,
      ));
    } catch (e) {
      if (state is! ProductDetailLoaded) {
        emit(const ProductDetailError(
          message: 'Không thể tải thông tin chi tiết sản phẩm. Vui lòng thử lại.',
        ));
      }
    }
  }

  void selectSize(String size) {
    if (state is ProductDetailLoaded) {
      emit((state as ProductDetailLoaded).copyWith(selectedSize: size));
    }
  }

  void selectColor(int color) {
    if (state is ProductDetailLoaded) {
      emit((state as ProductDetailLoaded).copyWith(selectedColor: color));
    }
  }

  void setActiveImageIndex(int index) {
    if (state is ProductDetailLoaded) {
      emit((state as ProductDetailLoaded).copyWith(activeImageIndex: index));
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

  void toggleFavorite() {
    if (state is ProductDetailLoaded) {
      final current = state as ProductDetailLoaded;
      emit(current.copyWith(isFavorite: !current.isFavorite));
    }
  }
}
