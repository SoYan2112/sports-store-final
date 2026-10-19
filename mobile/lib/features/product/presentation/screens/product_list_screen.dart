import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/product_card.dart';
import '../widgets/product_card_skeleton.dart';
import '../cubit/filter_cubit.dart';
import '../cubit/filter_state.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'product_detail_screen.dart';
import 'search_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const ProductListScreen({
    super.key,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
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
    // Kích hoạt tải danh sách sản phẩm lần đầu (kèm lọc theo danh mục nếu có)
    context.read<ProductBloc>().add(FetchProductsEvent(categoryId: widget.categoryId));

    // Thiết lập Infinite Scroll: kích hoạt FetchMoreProductsEvent khi cuộn gần cuối danh sách
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isNearBottom) {
      context.read<ProductBloc>().add(const FetchMoreProductsEvent());
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Khi còn cách đáy 200 pixel thì trigger tải trang tiếp theo
    return currentScroll >= (maxScroll - 200);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<ProductBloc>().add(const FetchProductsEvent(isRefresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: Colors.white,
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Header & App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: Navigator.canPop(context)
                                  ? () => Navigator.pop(context)
                                  : null,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Navigator.canPop(context)
                                      ? Icons.arrow_back_ios_new_rounded
                                      : Icons.grid_view_rounded,
                                  size: 20,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                widget.categoryName ?? 'Sports Store',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          // Nút thông báo
                          Stack(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.notifications_none_rounded,
                                  size: 24,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 12,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Thanh tìm kiếm
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(SearchScreen.route());
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color: Colors.grey.shade400,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Tìm kiếm sản phẩm thể thao...',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        key: const Key('product_filter_button'),
                        onTap: () => FilterBottomSheet.show(context),
                        borderRadius: BorderRadius.circular(16),
                        child: BlocBuilder<FilterCubit, FilterState>(
                          builder: (context, filterState) {
                            final hasActive = !filterState.isDefault;
                            return Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.tune_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  if (hasActive)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${filterState.activeFilterCount}',
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Danh sách lọc Thương hiệu (Brand Pill Selector)
              BlocBuilder<FilterCubit, FilterState>(
                builder: (context, filterState) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: SizedBox(
                        height: 42,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _brands.length,
                          itemBuilder: (context, index) {
                            final isSelected = index == 0
                                ? filterState.selectedBrands.isEmpty
                                : filterState.selectedBrands.contains(_brands[index]);
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: () {
                                  final brand = index == 0 ? null : _brands[index];
                                  context.read<FilterCubit>().updateFilter(
                                    brands: brand == null ? [] : [brand],
                                    categories: filterState.selectedCategories,
                                    minPrice: filterState.minPrice,
                                    maxPrice: filterState.maxPrice,
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? AppColors.primary.withValues(
                                                alpha: 0.25,
                                              )
                                            : Colors.black.withValues(alpha: 0.02),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      _brands[index],
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 4. Section Title: "Sản phẩm nổi bật"
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sản phẩm phổ biến',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Xem tất cả',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Grid View 2 Cột với BlocBuilder
              BlocBuilder<FilterCubit, FilterState>(
                builder: (context, filterState) {
                  return BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state is ProductLoading) {
                        // Hiển thị skeleton loading 6 ô dạng lưới 2 cột
                        return SliverPadding(
                          padding: const EdgeInsets.all(20),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 16,
                                ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => const ProductCardSkeleton(),
                              childCount: 6,
                            ),
                          ),
                        );
                      } else if (state is ProductError) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_off_rounded,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    state.message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<ProductBloc>().add(
                                        const FetchProductsEvent(),
                                      );
                                    },
                                    child: const Text('Thử lại'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else if (state is ProductLoaded) {
                        final filteredProducts = state.products
                            .where((p) => filterState.matches(p))
                            .toList();

                        if (filteredProducts.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Không tìm thấy sản phẩm phù hợp.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  if (!filterState.isDefault) ...[
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      key: const Key('product_reset_filter_button'),
                                      onPressed: () =>
                                          context.read<FilterCubit>().reset(),
                                      icon: const Icon(Icons.refresh_rounded, size: 18),
                                      label: const Text('Đặt lại bộ lọc'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }

                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 16,
                                ),
                            delegate: SliverChildBuilderDelegate((context, index) {
                              final product = filteredProducts[index];
                              return ProductCard(
                                product: product,
                                onTap: () {
                                  Navigator.of(context).push(
                                    ProductDetailScreen.route(product),
                                  );
                                },
                              );
                            }, childCount: filteredProducts.length),
                          ),
                        );
                      }

                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  );
                },
              ),

              // 6. Loading Indicator phía dưới khi Infinite Scroll (FetchMoreProducts)
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoaded && state.isLoadingMore) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox(height: 20));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
