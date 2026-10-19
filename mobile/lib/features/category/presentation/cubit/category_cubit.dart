import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;

  CategoryCubit({required this.getCategoriesUseCase})
      : super(const CategoryInitial());

  Future<void> fetchCategories() async {
    emit(const CategoryLoading());
    try {
      final categories = await getCategoriesUseCase();
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError(
        message: 'Không thể tải danh sách danh mục thể thao. Vui lòng thử lại.',
      ));
    }
  }
}

