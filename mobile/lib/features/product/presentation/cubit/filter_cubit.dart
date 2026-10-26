import 'package:flutter_bloc/flutter_bloc.dart';
import 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit() : super(const FilterState());

  /// Cập nhật toàn bộ tiêu chí lọc cùng lúc (từ BottomSheet khi nhấn Áp dụng)
  void updateFilter({
    required List<String> brands,
    required List<String> categories,
    required double minPrice,
    required double maxPrice,
  }) {
    emit(
      state.copyWith(
        selectedBrands: List<String>.unmodifiable(brands),
        selectedCategories: List<String>.unmodifiable(categories),
        minPrice: minPrice,
        maxPrice: maxPrice,
      ),
    );
  }

  /// Bật/tắt một thương hiệu
  void toggleBrand(String brand) {
    final currentBrands = List<String>.from(state.selectedBrands);
    if (currentBrands.contains(brand)) {
      currentBrands.remove(brand);
    } else {
      currentBrands.add(brand);
    }
    emit(state.copyWith(selectedBrands: currentBrands));
  }

  /// Bật/tắt một danh mục con / phân loại
  void toggleCategory(String category) {
    final currentCategories = List<String>.from(state.selectedCategories);
    if (currentCategories.contains(category)) {
      currentCategories.remove(category);
    } else {
      currentCategories.add(category);
    }
    emit(state.copyWith(selectedCategories: currentCategories));
  }

  /// Đặt khoảng giá min - max
  void setPriceRange(double min, double max) {
    emit(state.copyWith(minPrice: min, maxPrice: max));
  }

  /// Đặt lại toàn bộ bộ lọc về mặc định
  void reset() {
    emit(const FilterState());
  }
}
