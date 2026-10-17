import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../cubit/filter_cubit.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _tempBrand;
  late RangeValues _tempRange;

  final List<String> _brands = [
    'Tất cả',
    'Nike',
    'Adidas',
    'Puma',
    'Reebok',
    'Under Armour',
  ];

  @override
  void initState() {
    super.initState();
    final currentState = context.read<FilterCubit>().state;
    _tempBrand = currentState.selectedBrand;
    _tempRange = RangeValues(currentState.minPrice, currentState.maxPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh kéo nhỏ trên đầu
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
          const SizedBox(height: 14),

          // Tiêu đề & nút đóng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bộ lọc sản phẩm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(),

          // 1. Lọc theo thương hiệu
          const Text(
            'Thương hiệu',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _brands.map((brand) {
              final isSelected = _tempBrand == brand;
              return ChoiceChip(
                label: Text(brand),
                selected: isSelected,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey.shade100,
                onSelected: (_) {
                  setState(() => _tempBrand = brand);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // 2. Lọc theo khoảng giá
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Khoảng giá',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                '${CurrencyFormatter.formatVnd(_tempRange.start.toInt())} - ${CurrencyFormatter.formatVnd(_tempRange.end.toInt())}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          RangeSlider(
            min: 0,
            max: 5000000,
            divisions: 50,
            activeColor: AppColors.primary,
            inactiveColor: Colors.grey.shade200,
            values: _tempRange,
            onChanged: (newRange) {
              setState(() => _tempRange = newRange);
            },
          ),
          const SizedBox(height: 20),

          // 3. Hai nút: Đặt lại & Áp dụng
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _tempBrand = 'Tất cả';
                      _tempRange = const RangeValues(0, 5000000);
                    });
                    context.read<FilterCubit>().reset();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Đặt lại'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    context.read<FilterCubit>().updateFilter(
                          brand: _tempBrand,
                          minPrice: _tempRange.start,
                          maxPrice: _tempRange.end,
                        );
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Áp dụng',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
