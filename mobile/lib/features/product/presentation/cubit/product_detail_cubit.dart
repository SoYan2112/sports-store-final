import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_product_detail_usecase.dart';
import 'product_detail_state.dart';

// Quản lý chi tiết sản phẩm (UC-05)
class ProductDetailCubit extends Cubit<ProductDetailState> {
  final GetProductDetailUseCase getProductDetailUseCase;

  ProductDetailCubit({required this.getProductDetailUseCase})
      : super(const ProductDetailInitial());

  // Tải chi tiết sản phẩm
  Future<void> loadProduct(String id, {ProductEntity? initialProduct}) async {
    // 1. Nạp cache trước để render ngay
    if (initialProduct != null) {
      emit(ProductDetailLoaded(product: initialProduct));
    } else {
      emit(const ProductDetailLoading());
    }

    try {
      // 2. Gọi usecase lấy chi tiết từ server
      final product = await getProductDetailUseCase(id);
      final currentQty = (state is ProductDetailLoaded)
          ? (state as ProductDetailLoaded).quantity
          : 1;

      // 3. Emit Loaded với dữ liệu mới
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

  // Tăng số lượng
  void incrementQuantity() {
    if (state is ProductDetailLoaded) {
      final current = state as ProductDetailLoaded;
      // Không vượt quá tồn kho (stock)
      if (current.quantity < current.product.stock) {
        emit(current.copyWith(quantity: current.quantity + 1));
      }
    }
  }

  // Giảm số lượng
  void decrementQuantity() {
    if (state is ProductDetailLoaded) {
      final current = state as ProductDetailLoaded;
      // Tối thiểu là 1
      if (current.quantity > 1) {
        emit(current.copyWith(quantity: current.quantity - 1));
      }
    }
  }

  // Cập nhật biến thể kích thước (Size) của sản phẩm (UC-06)
  // Chọn size
  void selectSize(String size) {
    if (state is ProductDetailLoaded) {
      final current = state as ProductDetailLoaded;
      // Kiểm tra nếu kích thước thuộc danh sách hết hàng thì không cho chọn
      if (current.outOfStockSizes.contains(size)) return;
      // Cập nhật size đã chọn
      // Cập nhật size vào state để UI highlight kích thước và kích hoạt nút thêm giỏ hàng
      emit(current.copyWith(selectedSize: size));
    }
  }

  // Cập nhật biến thể màu sắc (Color) của sản phẩm (UC-06)
  // Chọn màu
  void selectColor(int color) {
    if (state is ProductDetailLoaded) {
      final current = state as ProductDetailLoaded;
      // Cập nhật mã màu vào state để UI hiển thị viền highlight và icon check
      emit(current.copyWith(selectedColor: color));
    }
  }
}
