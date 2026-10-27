import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../product/presentation/bloc/product_event.dart';
import '../../../product/presentation/bloc/product_state.dart';
import '../../../product/presentation/screens/product_detail_screen.dart';
import '../../../product/presentation/screens/product_list_screen.dart';
import '../../../product/presentation/screens/search_screen.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../../../product/presentation/widgets/product_card_skeleton.dart';
import '../../../product/presentation/cubit/filter_cubit.dart';
import '../../../product/presentation/cubit/filter_state.dart';
import '../../../product/presentation/widgets/filter_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onSeeAllTap;

  const HomeScreen({super.key, this.onSeeAllTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  String? _selectedCategoryId;
  String? _selectedCategoryName;

  int _selectedBrandIndex = 0;
  final List<String> _brands = [
    'Tất cả',
    'Nike',
    'Adidas',
    'Puma',
    'Reebok',
    'Under Armour',
  ];

  final List<Map<String, String>> _banners = [
    {
      'title': 'SUMMER SPORT SALE',
      'subtitle': 'Giảm đến 40% giày chạy bộ cao cấp',
      'badge': 'Ưu đãi hot',
      'image':
          'https://images.unsplash.com/photo-1556906781-9a412961c28c?w=800&auto=format&fit=crop&q=80',
    },
    {
      'title': 'NEW COLLECTION 2026',
      'subtitle': 'Đệm khí Joyride & Boost trợ lực tối đa',
      'badge': 'Hàng mới về',
      'image':
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&auto=format&fit=crop&q=80',
    },
    {
      'title': 'FREESHIP EXTRA',
      'subtitle': 'Miễn phí vận chuyển toàn quốc đơn từ 500k',
      'badge': 'Freeship',
      'image':
          'https://images.unsplash.com/photo-1579338559194-a162d19bf842?w=800&auto=format&fit=crop&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Kích hoạt lấy sản phẩm nếu chưa có
    final productBloc = context.read<ProductBloc>();
    if (productBloc.state is ProductInitial) {
      productBloc.add(const FetchProductsEvent());
    }

    // Tự động chuyển banner sau mỗi 4 giây
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        final nextIndex = (_currentBannerIndex + 1) % _banners.length;
        _bannerController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _onSelectCategory(String? categoryId, String? categoryName) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedCategoryName = categoryName;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final brand = _selectedBrandIndex == 0 ? null : _brands[_selectedBrandIndex];
    context.read<ProductBloc>().add(
      FetchProductsEvent(
        categoryId: _selectedCategoryId,
        keyword: brand,
        isRefresh: true,
      ),
    );
  }

  void _showCategoryBottomSheet() {
    final categories = [
      {
        'id': null,
        'name': 'Tất cả danh mục',
        'subtitle': 'Xem tất cả sản phẩm thể thao',
        'icon': Icons.all_inclusive_rounded,
      },
      {
        'id': 'cat_shoes',
        'name': 'Giày thể thao',
        'subtitle': 'Chạy bộ, bóng rổ, training trợ lực',
        'icon': Icons.directions_run_rounded,
      },
      {
        'id': 'cat_tops',
        'name': 'Áo thể thao',
        'subtitle': 'Áo thun thoáng khí, áo khoác gió',
        'icon': Icons.checkroom_rounded,
      },
      {
        'id': 'cat_bottoms',
        'name': 'Quần thể thao',
        'subtitle': 'Quần shorts 2-in-1, quần jogger',
        'icon': Icons.straighten_rounded,
      },
      {
        'id': 'cat_accessories',
        'name': 'Phụ kiện thể thao',
        'subtitle': 'Balo chống nước, mũ, tất thể thao',
        'icon': Icons.backpack_outlined,
      },
      {
        'id': 'cat_gear',
        'name': 'Dụng cụ tập luyện',
        'subtitle': 'Dây kháng lực, thảm tập Yoga',
        'icon': Icons.fitness_center_rounded,
      },
      {
        'id': 'cat_protection',
        'name': 'Đồ bảo hộ & Hỗ trợ',
        'subtitle': 'Băng đầu gối, băng cuốn cổ tay',
        'icon': Icons.health_and_safety_outlined,
      },
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Danh mục thể thao',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final catId = cat['id'] as String?;
                      final isSelected = _selectedCategoryId == catId;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFFFEFE6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            cat['icon'] as IconData,
                            color: isSelected ? Colors.white : AppColors.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          cat['name'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          cat['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                            : null,
                        onTap: () {
                          Navigator.pop(ctx);
                          _onSelectCategory(catId, catId == null ? null : cat['name'] as String?);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToProductList() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductListScreen(
          categoryId: _selectedCategoryId,
          categoryName: _selectedCategoryName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            context.read<ProductBloc>().add(const FetchProductsEvent(isRefresh: true));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Header: Chào hỏi & Chuông thông báo
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.sports_basketball_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  final name = (state is AuthAuthenticated)
                                      ? state.userName
                                      : 'Khách hàng';
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Xin chào, $name 👋',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        state is AuthAuthenticated
                                            ? 'Chào mừng bạn quay trở lại'
                                            : 'Khám phá đồ thể thao cao cấp',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(SearchScreen.route());
                            },
                            borderRadius: BorderRadius.circular(14),
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
                              child: const Icon(
                                Icons.search_rounded,
                                size: 22,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            key: const Key('home_category_button'),
                            onTap: _showCategoryBottomSheet,
                            borderRadius: BorderRadius.circular(14),
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
                              child: const Icon(
                                Icons.grid_view_rounded,
                                size: 22,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Banner Carousel tự động cuộn
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(
                      height: 170,
                      child: PageView.builder(
                        controller: _bannerController,
                        itemCount: _banners.length,
                        onPageChanged: (index) {
                          setState(() => _currentBannerIndex = index);
                        },
                        itemBuilder: (context, index) {
                          final banner = _banners[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage(banner['image'] ?? ''),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withValues(alpha: 0.35),
                                    BlendMode.darken,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      banner['badge'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    banner['title'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    banner['subtitle'] ?? '',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Dots indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _banners.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentBannerIndex == index ? 22 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentBannerIndex == index
                                ? AppColors.primary
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Brand Pill Filter & Nút Filter nhỏ bên phải ngang hàng
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                  child: SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        // Danh sách thương hiệu cuộn ngang
                        Expanded(
                          child: BlocBuilder<FilterCubit, FilterState>(
                            builder: (context, filterState) {
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _brands.length,
                                itemBuilder: (context, index) {
                                  final isSelected = index == 0
                                      ? (filterState.selectedBrands.isEmpty &&
                                          _selectedBrandIndex == 0)
                                      : (filterState.selectedBrands
                                              .contains(_brands[index]) ||
                                          _selectedBrandIndex == index);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(
                                            () => _selectedBrandIndex = index);
                                        final brand = index == 0
                                            ? null
                                            : _brands[index];
                                        context
                                            .read<FilterCubit>()
                                            .updateFilter(
                                              brands: brand == null
                                                  ? []
                                                  : [brand],
                                              categories: filterState
                                                  .selectedCategories,
                                              minPrice:
                                                  filterState.minPrice,
                                              maxPrice:
                                                  filterState.maxPrice,
                                            );
                                        _applyFilters();
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.03),
                                              blurRadius: 6,
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
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Nút Icon Filter nhỏ nằm bên phải ngang hàng với Tất cả, Adidas...
                        BlocBuilder<FilterCubit, FilterState>(
                          builder: (context, filterState) {
                            final hasActive = !filterState.isDefault;
                            return InkWell(
                              key: const Key('home_filter_button'),
                              onTap: () => FilterBottomSheet.show(context),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: hasActive
                                      ? AppColors.primary
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: hasActive
                                          ? AppColors.primary
                                              .withValues(alpha: 0.25)
                                          : Colors.black
                                              .withValues(alpha: 0.03),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.tune_rounded,
                                      size: 20,
                                      color: hasActive
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                    if (hasActive)
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Section Header: "Sản phẩm phổ biến" & Nút "Xem tất cả"
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BlocBuilder<FilterCubit, FilterState>(
                        builder: (context, filterState) {
                          String title;
                          if (!filterState.isDefault) {
                            title = 'Sản phẩm lọc được';
                          } else if (_selectedCategoryName != null) {
                            title = 'Sản phẩm ${_selectedCategoryName!}';
                          } else if (_selectedBrandIndex != 0) {
                            title = 'Sản phẩm ${_brands[_selectedBrandIndex]}';
                          } else {
                            title = 'Sản phẩm phổ biến';
                          }
                          return Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          );
                        },
                      ),
                      TextButton(
                        onPressed: widget.onSeeAllTap ?? () => _navigateToProductList(),
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
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Grid 2 cột ngắn (hiển thị tối đa 4 sản phẩm)
              BlocBuilder<FilterCubit, FilterState>(
                builder: (context, filterState) {
                  return BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state is ProductLoading) {
                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 16,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => const ProductCardSkeleton(),
                              childCount: 4,
                            ),
                          ),
                        );
                      } else if (state is ProductLoaded) {
                        final filtered = state.products
                            .where((p) => filterState.matches(p))
                            .toList();
                        final featured = filtered.take(4).toList();
                        if (featured.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Column(
                                  children: [
                                    const Text(
                                      'Không có sản phẩm nào phù hợp.',
                                      style: TextStyle(color: AppColors.textSecondary),
                                    ),
                                    if (!filterState.isDefault) ...[
                                      const SizedBox(height: 8),
                                      TextButton(
                                        key: const Key('home_filter_reset_empty_button'),
                                        onPressed: () => context.read<FilterCubit>().reset(),
                                        child: const Text(
                                          'Đặt lại bộ lọc',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 16,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final product = featured[index];
                                return ProductCard(
                                  product: product,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      ProductDetailScreen.route(product),
                                    );
                                  },
                                );
                              },
                              childCount: featured.length,
                            ),
                          ),
                        );
                      }

                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
