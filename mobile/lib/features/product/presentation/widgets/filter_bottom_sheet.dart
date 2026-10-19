import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../cubit/filter_cubit.dart';
import '../cubit/filter_state.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  /// Phương thức static thuận tiện để mở FilterBottomSheet từ bất cứ màn hình nào
  static Future<bool?> show(BuildContext context) {
    final filterCubit = context.read<FilterCubit>();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: filterCubit,
        child: const FilterBottomSheet(),
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // Danh sách các hãng thể thao
  static const List<String> _brandOptions = [
    'Nike',
    'Adidas',
    'Puma',
    'Under Armour',
    'Reebok',
    'Asics',
  ];

  // Danh sách danh mục / phân loại phụ
  static const List<String> _categoryOptions = [
    'Giày thể thao',
    'Áo thể thao',
    'Quần thể thao',
    'Phụ kiện thể thao',
    'Dụng cụ tập luyện',
    'Đồ bảo hộ & Hỗ trợ',
  ];

  late List<String> _tempBrands;
  late List<String> _tempCategories;
  late double _tempMinPrice;
  late double _tempMaxPrice;

  @override
  void initState() {
    super.initState();
    final currentState = context.read<FilterCubit>().state;
    _tempBrands = List<String>.from(currentState.selectedBrands);
    _tempCategories = List<String>.from(currentState.selectedCategories);
    _tempMinPrice = currentState.minPrice;
    _tempMaxPrice = currentState.maxPrice;
  }

  void _resetLocal() {
    setState(() {
      _tempBrands.clear();
      _tempCategories.clear();
      _tempMinPrice = FilterState.minPriceLimit;
      _tempMaxPrice = FilterState.maxPriceLimit;
    });
  }

  void _applyFilter() {
    context.read<FilterCubit>().updateFilter(
          brands: _tempBrands,
          categories: _tempCategories,
          minPrice: _tempMinPrice,
          maxPrice: _tempMaxPrice,
        );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header: Tiêu đề và nút Đặt lại
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bộ lọc tìm kiếm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    key: const Key('filter_reset_button'),
                    onPressed: _resetLocal,
                    child: const Text(
                      'Đặt lại',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Nội dung cuộn được: Khoảng giá, Thương hiệu, Danh mục
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // --- 1. KHOẢNG GIÁ ---
                  const Text(
                    'Khoảng giá',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyFormatter.formatVnd(_tempMinPrice),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const Text(
                        'đến',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatVnd(_tempMaxPrice),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    key: const Key('filter_price_slider'),
                    values: RangeValues(_tempMinPrice, _tempMaxPrice),
                    min: FilterState.minPriceLimit,
                    max: FilterState.maxPriceLimit,
                    divisions: 50,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.grey.shade200,
                    onChanged: (values) {
                      setState(() {
                        _tempMinPrice = values.start;
                        _tempMaxPrice = values.end;
                      });
                    },
                  ),
                  // Phím tắt chọn khoảng giá nhanh
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildPresetChip('Dưới 2tr', 0, 2000000),
                      _buildPresetChip('2tr - 3.5tr', 2000000, 3500000),
                      _buildPresetChip('Trên 3.5tr', 3500000, 5000000),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- 2. THƯƠNG HIỆU ---
                  const Text(
                    'Thương hiệu',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _brandOptions.map((brand) {
                      final isSelected = _tempBrands.contains(brand);
                      return FilterChip(
                        key: Key('filter_brand_$brand'),
                        label: Text(brand),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _tempBrands.add(brand);
                            } else {
                              _tempBrands.remove(brand);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // --- 3. DANH MỤC / PHÂN LOẠI PHỤ ---
                  const Text(
                    'Danh mục / Phân loại',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categoryOptions.map((cat) {
                      final isSelected = _tempCategories.contains(cat);
                      return FilterChip(
                        key: Key('filter_category_$cat'),
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _tempCategories.add(cat);
                            } else {
                              _tempCategories.remove(cat);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),
            const SizedBox(height: 12),

            // Nút Áp dụng ở đáy
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  key: const Key('filter_apply_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _applyFilter,
                  child: const Text(
                    'Áp dụng bộ lọc',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, double min, double max) {
    final isSelected = _tempMinPrice == min && _tempMaxPrice == max;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
        ),
      ),
      onSelected: (_) {
        setState(() {
          _tempMinPrice = min;
          _tempMaxPrice = max;
        });
      },
    );
  }
}
