import 'package:flutter_bloc/flutter_bloc.dart';
import 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit() : super(const FilterState());

  void updateFilter({
    required String brand,
    required double minPrice,
    required double maxPrice,
  }) {
    emit(FilterState(
      selectedBrand: brand,
      minPrice: minPrice,
      maxPrice: maxPrice,
    ));
  }

  void reset() {
    emit(const FilterState());
  }
}
