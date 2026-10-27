import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
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
        final quantity = state is ProductDetailLoaded ? state.quantity : 1;
        final selectedSize = state is ProductDetailLoaded ? state.selectedSize : null;
        final selectedColor = state is ProductDetailLoaded ? state.selectedColor : null;
        final outOfStockSizes = state is ProductDetailLoaded
            ? state.outOfStockSizes
            : const <String>['43'];
        final canAddToCart = state is ProductDetailLoaded && state.canAddToCart;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chi tiết sản phẩm'),
            centerTitle: true,
            actions: [
              BlocBuilder<CartBloc, CartState>(
                builder: (context, cartState) {
                  final count = cartState is CartLoaded ? cartState.totalQuantity : 0;
                  return IconButton(
                    icon: Badge(
                      isLabelVisible: count > 0,
                      label: Text(''),
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.shopping_bag_outlined),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  );
                },
              ),
            ],
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
                      // Chọn Màu sắc
                      const Text(
                        'Màu sắc:',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        children: product.colors.map((colorValue) {
                          final isSelected = selectedColor == colorValue;
                          return GestureDetector(
                            key: Key('color_${colorValue.toRadixString(16)}'),
                            onTap: () {
                              context.read<ProductDetailCubit>().selectColor(colorValue);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(colorValue),
                                  border: Border.all(
                                    color: colorValue == 0xFFFFFFFF
                                        ? Colors.grey.shade400
                                        : Colors.black.withValues(alpha: 0.08),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        size: 16,
                                        color: colorValue == 0xFFFFFFFF
                                            ? Colors.black
                                            : Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      // Chọn Kích thước (Size)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kích thước (Size):',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          if (selectedSize != null)
                            Text(
                              'Đã chọn: $selectedSize',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: product.sizes.map((size) {
                          final isOutOfStock = outOfStockSizes.contains(size);
                          final isSelected = selectedSize == size;

                          return InkWell(
                            key: Key('size_$size'),
                            onTap: isOutOfStock
                                ? null
                                : () {
                                    context.read<ProductDetailCubit>().selectSize(size);
                                  },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isOutOfStock ? Colors.grey.shade100 : Colors.white),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isOutOfStock
                                      ? Colors.grey.shade300
                                      : (isSelected ? AppColors.primary : Colors.grey.shade400),
                                ),
                              ),
                              child: Text(
                                size,
                                style: TextStyle(
                                  color: isOutOfStock
                                      ? Colors.grey.shade400
                                      : (isSelected ? Colors.white : Colors.black87),
                                  fontWeight: FontWeight.bold,
                                  decoration: isOutOfStock ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const Divider(height: 30),
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
                    key: const Key('addToCartButton'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: canAddToCart
                        ? () {
                            final cartItem = CartItemEntity(
                              id: CartItemEntity.generateId(
                                product.id,
                                selectedSize!,
                                selectedColor ?? 0xFF1A1A1A,
                              ),
                              productId: product.id,
                              name: product.name,
                              brand: product.brand,
                              price: product.price,
                              imageUrl: product.imageUrl,
                              selectedSize: selectedSize,
                              selectedColor: selectedColor ?? 0xFF1A1A1A,
                              quantity: quantity,
                              stock: product.stock,
                            );
                            context.read<CartBloc>().add(AddToCartEvent(cartItem));
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.textPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.greenAccent,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Đã thêm $quantity x ${product.name} (Size $selectedSize) vào giỏ hàng!',
                                        style: const TextStyle(color: Colors.white, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                action: SnackBarAction(
                                  label: 'Xem giỏ',
                                  textColor: AppColors.primary,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const CartScreen()),
                                    );
                                  },
                                ),
                              ),
                            );
                          }
                        : null,
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
