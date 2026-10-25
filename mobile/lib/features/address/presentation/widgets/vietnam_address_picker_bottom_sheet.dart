import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/datasources/vietnam_divisions_data.dart';

class AddressPickerResult {
  final String province;
  final String district;
  final String ward;

  const AddressPickerResult({
    required this.province,
    required this.district,
    required this.ward,
  });

  String get summary => '$ward, $district, $province';
}

class VietnamAddressPickerBottomSheet extends StatefulWidget {
  final String? initialProvince;
  final String? initialDistrict;
  final String? initialWard;

  const VietnamAddressPickerBottomSheet({
    super.key,
    this.initialProvince,
    this.initialDistrict,
    this.initialWard,
  });

  static Future<AddressPickerResult?> show(
    BuildContext context, {
    String? initialProvince,
    String? initialDistrict,
    String? initialWard,
  }) {
    return showModalBottomSheet<AddressPickerResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VietnamAddressPickerBottomSheet(
        initialProvince: initialProvince,
        initialDistrict: initialDistrict,
        initialWard: initialWard,
      ),
    );
  }

  @override
  State<VietnamAddressPickerBottomSheet> createState() =>
      _VietnamAddressPickerBottomSheetState();
}

class _VietnamAddressPickerBottomSheetState
    extends State<VietnamAddressPickerBottomSheet> {
  // Step 0: Province, Step 1: District, Step 2: Ward
  int _currentStep = 0;

  ProvinceData? _selectedProvince;
  DistrictData? _selectedDistrict;
  String? _selectedWard;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Khởi tạo nếu có dữ liệu truyền vào trước đó
    if (widget.initialProvince != null) {
      try {
        _selectedProvince = VietnamAdministrativeData.provinces.firstWhere(
          (p) => p.name == widget.initialProvince,
        );
        if (widget.initialDistrict != null && _selectedProvince != null) {
          _selectedDistrict = _selectedProvince!.districts.firstWhere(
            (d) => d.name == widget.initialDistrict,
          );
          if (widget.initialWard != null && _selectedDistrict != null) {
            _selectedWard = widget.initialWard;
          }
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getFilteredItems() {
    final query = _searchQuery.toLowerCase().trim();
    if (_currentStep == 0) {
      final names =
          VietnamAdministrativeData.provinces.map((p) => p.name).toList();
      if (query.isEmpty) return names;
      return names.where((n) => n.toLowerCase().contains(query)).toList();
    } else if (_currentStep == 1) {
      final districts =
          _selectedProvince?.districts.map((d) => d.name).toList() ?? [];
      if (query.isEmpty) return districts;
      return districts.where((n) => n.toLowerCase().contains(query)).toList();
    } else {
      final wards = _selectedDistrict?.wards ?? [];
      if (query.isEmpty) return wards;
      return wards.where((n) => n.toLowerCase().contains(query)).toList();
    }
  }

  void _onItemSelected(String item) {
    _searchController.clear();
    _searchQuery = '';

    if (_currentStep == 0) {
      setState(() {
        _selectedProvince = VietnamAdministrativeData.provinces.firstWhere(
          (p) => p.name == item,
        );
        _selectedDistrict = null;
        _selectedWard = null;
        _currentStep = 1;
      });
    } else if (_currentStep == 1) {
      setState(() {
        _selectedDistrict = _selectedProvince?.districts.firstWhere(
          (d) => d.name == item,
        );
        _selectedWard = null;
        _currentStep = 2;
      });
    } else {
      setState(() {
        _selectedWard = item;
      });
      // Hoàn tất chọn đủ 3 cấp
      if (_selectedProvince != null && _selectedDistrict != null) {
        Navigator.of(context).pop(
          AddressPickerResult(
            province: _selectedProvince!.name,
            district: _selectedDistrict!.name,
            ward: item,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _getFilteredItems();

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Header title & close
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chọn khu vực giao hàng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Stepper breadcrumbs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppColors.background,
            child: Row(
              children: [
                _buildStepTab(
                  index: 0,
                  label: _selectedProvince?.name ?? 'Tỉnh / Thành phố',
                  isSelected: _currentStep == 0,
                  isDone: _selectedProvince != null,
                ),
                const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                _buildStepTab(
                  index: 1,
                  label: _selectedDistrict?.name ?? 'Quận / Huyện',
                  isSelected: _currentStep == 1,
                  isDone: _selectedDistrict != null,
                  isEnabled: _selectedProvince != null,
                ),
                const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                _buildStepTab(
                  index: 2,
                  label: _selectedWard ?? 'Phường / Xã',
                  isSelected: _currentStep == 2,
                  isDone: _selectedWard != null,
                  isEnabled: _selectedDistrict != null,
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: _currentStep == 0
                    ? 'Tìm Tỉnh / Thành phố...'
                    : _currentStep == 1
                        ? 'Tìm Quận / Huyện...'
                        : 'Tìm Phường / Xã...',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Items List
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'Không tìm thấy kết quả phù hợp',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (context, index) {
                      final name = items[index];
                      final isSelected = (_currentStep == 0 &&
                              _selectedProvince?.name == name) ||
                          (_currentStep == 1 &&
                              _selectedDistrict?.name == name) ||
                          (_currentStep == 2 && _selectedWard == name);

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                                size: 20,
                              )
                            : null,
                        onTap: () => _onItemSelected(name),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTab({
    required int index,
    required String label,
    required bool isSelected,
    required bool isDone,
    bool isEnabled = true,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: isEnabled
            ? () {
                setState(() {
                  _currentStep = index;
                  _searchController.clear();
                  _searchQuery = '';
                });
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bước ${index + 1}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.primary
                      : isEnabled
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : isDone
                          ? AppColors.textPrimary
                          : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
