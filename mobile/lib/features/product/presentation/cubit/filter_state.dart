import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

class FilterState extends Equatable {
  static const double minPriceLimit = 0;
  static const double maxPriceLimit = 5000000;

  final List<String> selectedBrands;
  final List<String> selectedCategories;
  final double minPrice;
  final double maxPrice;

  const FilterState({
    this.selectedBrands = const [],
    this.selectedCategories = const [],
    this.minPrice = minPriceLimit,
    this.maxPrice = maxPriceLimit,
  });

  bool get isDefault =>
      selectedBrands.isEmpty &&
      selectedCategories.isEmpty &&
      minPrice == minPriceLimit &&
      maxPrice == maxPriceLimit;

  int get activeFilterCount {
    var count = 0;
    count += selectedBrands.length;
    count += selectedCategories.length;
    if (minPrice > minPriceLimit || maxPrice < maxPriceLimit) {
      count += 1;
    }
    return count;
  }

  bool matches(ProductEntity product) {
    if (selectedBrands.isNotEmpty && !selectedBrands.contains(product.brand)) {
      return false;
    }
    if (selectedCategories.isNotEmpty &&
        !selectedCategories.contains(product.category)) {
      return false;
    }
    if (product.price < minPrice || product.price > maxPrice) {
      return false;
    }
    return true;
  }

  FilterState copyWith({
    List<String>? selectedBrands,
    List<String>? selectedCategories,
    double? minPrice,
    double? maxPrice,
  }) {
    return FilterState(
      selectedBrands: selectedBrands ?? this.selectedBrands,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  @override
  List<Object?> get props => [
        selectedBrands,
        selectedCategories,
        minPrice,
        maxPrice,
      ];
}
