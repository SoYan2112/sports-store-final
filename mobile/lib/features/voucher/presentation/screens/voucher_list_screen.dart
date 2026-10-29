import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/voucher_entity.dart';
import '../cubit/voucher_cubit.dart';
import '../cubit/voucher_state.dart';
import '../widgets/voucher_card.dart';

class VoucherListScreen extends StatelessWidget {
  final VoucherCubit? cubit;
  final bool isSelectMode;
  final double? currentOrderValue;

  const VoucherListScreen({
    super.key,
    this.cubit,
    this.isSelectMode = false,
    this.currentOrderValue,
  });

  static Route<VoucherEntity?> route({
    bool isSelectMode = false,
    double? currentOrderValue,
    VoucherCubit? cubit,
  }) {
    return MaterialPageRoute<VoucherEntity?>(
      builder: (_) => VoucherListScreen(
        cubit: cubit,
        isSelectMode: isSelectMode,
        currentOrderValue: currentOrderValue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCubit = cubit;
    if (activeCubit != null) {
      return BlocProvider<VoucherCubit>.value(
        value: activeCubit,
        child: _VoucherListView(
          isSelectMode: isSelectMode,
          currentOrderValue: currentOrderValue,
        ),
      );
    }

    return BlocProvider<VoucherCubit>(
      create: (_) => getIt<VoucherCubit>()..fetchVouchers(),
      child: _VoucherListView(
        isSelectMode: isSelectMode,
        currentOrderValue: currentOrderValue,
      ),
    );
  }
}

class _VoucherListView extends StatefulWidget {
  final bool isSelectMode;
  final double? currentOrderValue;

  const _VoucherListView({
    this.isSelectMode = false,
    this.currentOrderValue,
  });

  @override
  State<_VoucherListView> createState() => _VoucherListViewState();
}

class _VoucherListViewState extends State<_VoucherListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedFilterIndex = 0; // 0: Tất cả, 1: Giảm giá, 2: Freeship

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<VoucherEntity> _filterVouchers(List<VoucherEntity> vouchers) {
    List<VoucherEntity> result = vouchers;

    // 1. Lọc theo tab danh mục
    switch (_selectedFilterIndex) {
      case 1:
        result = result
            .where((v) =>
                v.type == VoucherType.percentage ||
                v.type == VoucherType.fixedAmount)
            .toList();
        break;
      case 2:
        result = result
            .where((v) => v.type == VoucherType.freeShipping)
            .toList();
        break;
      default:
        break;
    }

    // 2. Lọc theo từ khóa tìm kiếm (mã voucher, tiêu đề, mô tả)
    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((v) {
        final codeMatch = v.code.toLowerCase().contains(query);
        final titleMatch = v.title.toLowerCase().contains(query);
        final descMatch = v.description.toLowerCase().contains(query);
        return codeMatch || titleMatch || descMatch;
      }).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isSelectMode ? 'Chọn Voucher' : 'Kho Voucher & Ưu Đãi',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<VoucherCubit, VoucherState>(
        builder: (context, state) {
          if (state is VoucherLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is VoucherError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () =>
                          context.read<VoucherCubit>().fetchVouchers(),
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is VoucherLoaded) {
            final allVouchers = state.vouchers;
            final displayedVouchers = _filterVouchers(allVouchers);

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<VoucherCubit>().fetchVouchers(),
              child: Column(
                children: [
                  // 1. Thanh tìm kiếm voucher
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 22,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Tìm kiếm voucher theo tên, mã...',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: Icon(
                                Icons.cancel,
                                size: 18,
                                color: Colors.grey.shade500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Bộ lọc tab/chips
                  Container(
                    color: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'Tất cả (${allVouchers.length})',
                          index: 0,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Giảm giá',
                          index: 1,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Freeship',
                          index: 2,
                        ),
                      ],
                    ),
                  ),

                  const Divider(
                      height: 1, thickness: 1, color: AppColors.divider),

                  // 3. Danh sách voucher
                  Expanded(
                    child: displayedVouchers.isEmpty
                        ? _buildEmptyView()
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: displayedVouchers.length,
                            itemBuilder: (context, index) {
                              final voucher = displayedVouchers[index];
                              return VoucherCard(
                                voucher: voucher,
                                onApply: widget.isSelectMode
                                    ? () {
                                        if (widget.currentOrderValue != null &&
                                            widget.currentOrderValue! <
                                                voucher.minOrderValue) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Đơn hàng chưa đạt giá trị tối thiểu ${voucher.formattedMinOrder}.',
                                              ),
                                              backgroundColor: Colors.red,
                                              duration:
                                                  const Duration(seconds: 2),
                                            ),
                                          );
                                          return;
                                        }
                                        Navigator.of(context).pop(voucher);
                                      }
                                    : null,
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFilterChip({required String label, required int index}) {
    final isSelected = _selectedFilterIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    final isSearching = _searchQuery.trim().isNotEmpty;
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.local_offer_outlined,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? 'Không tìm thấy voucher phù hợp'
                  : 'Không có mã giảm giá phù hợp',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Không có voucher nào khớp với từ khóa "$_searchQuery". Hãy thử kiểm tra lại mã hoặc tên ưu đãi.'
                  : 'Các chương trình ưu đãi mới sẽ liên tục được cập nhật. Hãy quay lại sau nhé!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            if (isSearching) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear_rounded, size: 18),
                label: const Text('Xóa tìm kiếm'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
