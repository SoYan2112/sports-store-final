import 'package:equatable/equatable.dart';

class FilterState extends Equatable {
  final String selectedBrand;
  final double minPrice;
  final double maxPrice;

  const FilterState({
    this.selectedBrand = 'Tất cả',
    this.minPrice = 0,
    this.maxPrice = 5000000,
  });

  FilterState copyWith({
    String? selectedBrand,
    double? minPrice,
    double? maxPrice,
  }) {
    return FilterState(
      selectedBrand: selectedBrand ?? this.selectedBrand,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  bool get isDefault =>
      selectedBrand == 'Tất cả' && minPrice == 0 && maxPrice == 5000000;

  @override
  List<Object?> get props => [selectedBrand, minPrice, maxPrice];
}
