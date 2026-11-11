import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import 'category_state.dart';

// Quản lý trạng thái nạp và hiển thị danh mục sản phẩm thể thao (UC-16)
class CategoryCubit extends Cubit<CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;

  CategoryCubit({required this.getCategoriesUseCase})
      : super(const CategoryInitial());

  // Hàm tải danh sách danh mục từ UseCase (CSDL SQLite / API)
  Future<void> fetchCategories() async {
    // 1. Phát ra trạng thái đang tải (Loading) để hiển thị vòng xoay tiến trình
    emit(const CategoryLoading());
    try {
      // 2. Gọi UseCase lấy danh sách danh mục thể thao
      final categories = await getCategoriesUseCase();
      // 3. Phát ra trạng thái nạp thành công (Loaded) kèm danh sách danh mục để vẽ UI
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      // 4. Bắt ngoại lệ và phát ra thông báo lỗi (Error)
      emit(CategoryError(
        message: 'Không thể tải danh sách danh mục thể thao. Vui lòng thử lại.',
      ));
    }
  }
}

