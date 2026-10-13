import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/product_entity.dart';
import '../cubit/product_detail_cubit.dart';
import '../cubit/product_detail_state.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  static Route route(ProductEntity product) {
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => getIt<ProductDetailCubit>()
          ..loadProduct(product.id, initialProduct: product),
        child: ProductDetailScreen(product: product),
      ),
    );
  }

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailCubit, ProductDetailState>(
      builder: (context, state) {
        final product = state is ProductDetailLoaded ? state.product : widget.product;
        final selectedSize = state is ProductDetailLoaded
            ? state.selectedSize
            : (product.sizes.isNotEmpty ? product.sizes.first : null);
        final quantity = state is ProductDetailLoaded ? state.quantity : 1;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chi tiết sản phẩm'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.network(
                    product.imageUrl,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 260,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.brand.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text('${product.rating} (${product.reviewCount} đánh giá)'),
                          const Spacer(),
                          Text(
                            product.stock > 0 ? 'Còn ${product.stock} sản phẩm' : 'Hết hàng',
                            style: TextStyle(
                              color: product.stock > 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        CurrencyFormatter.formatVnd(product.price),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const Divider(height: 30),
                      const Text(
                        'Chọn kích cỡ:',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: product.sizes.map((size) {
                          final isSelected = size == selectedSize;
                          return ChoiceChip(
                            label: Text(size),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (_) {
                              context.read<ProductDetailCubit>().selectSize(size);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            'Số lượng:',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              context.read<ProductDetailCubit>().decrementQuantity();
                            },
                          ),
                          Text(
                            '$quantity',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              context.read<ProductDetailCubit>().incrementQuantity();
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 30),
                      Text(
                        'Danh mục: ${product.category}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Mô tả sản phẩm:',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.description.isNotEmpty
                            ? product.description
                            : 'Sản phẩm thể thao cao cấp chính hãng.',
                        style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey.shade800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tổng tiền:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      CurrencyFormatter.formatVnd(product.price * quantity),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: product.stock <= 0
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Đã thêm $quantity x ${product.name} (Size $selectedSize) vào giỏ hàng!',
                                ),
                              ),
                            );
                          },
                    child: const Text(
                      'Thêm vào giỏ hàng',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
