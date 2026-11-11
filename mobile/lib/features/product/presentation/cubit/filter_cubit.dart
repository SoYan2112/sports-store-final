import 'package:flutter_bloc/flutter_bloc.dart';
import 'filter_state.dart';

// Quản lý bộ lọc sản phẩm (UC-17)
class FilterCubit extends Cubit<FilterState> {
  FilterCubit() : super(const FilterState());

  // Cập nhật bộ lọc
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

  // Chọn/bỏ thương hiệu
  void toggleBrand(String brand) {
    final currentBrands = List<String>.from(state.selectedBrands);
    if (currentBrands.contains(brand)) {
      currentBrands.remove(brand);
    } else {
      currentBrands.add(brand);
    }
    emit(state.copyWith(selectedBrands: currentBrands));
  }

  // Chọn/bỏ danh mục
  void toggleCategory(String category) {
    final currentCategories = List<String>.from(state.selectedCategories);
    if (currentCategories.contains(category)) {
      currentCategories.remove(category);
    } else {
      currentCategories.add(category);
    }
    emit(state.copyWith(selectedCategories: currentCategories));
  }

  // Đặt khoảng giá
  void setPriceRange(double min, double max) {
    emit(state.copyWith(minPrice: min, maxPrice: max));
  }

  // Đặt lại mặc định
  void reset() {
    emit(const FilterState());
  }
}
