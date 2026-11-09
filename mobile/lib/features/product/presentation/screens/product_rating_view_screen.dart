import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/product_entity.dart';
import 'product_rating_screen.dart';

class ProductRatingViewScreen extends StatelessWidget {
  final ProductEntity product;
  const ProductRatingViewScreen({super.key, required this.product});

  Future<void> _openAddRating(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductRatingScreen(
          product: product,
          userId: 'mock_user',
          userName: 'Bạn',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviews = [
      ('Nguyễn Minh', 5, 'Sản phẩm đẹp, chất lượng tốt và giao hàng nhanh.'),
      ('Trần Anh', 4, 'Đúng mô tả, mang khá êm và vừa size.'),
      ('Lê Hoàng', 5, 'Mình rất hài lòng, sẽ tiếp tục ủng hộ shop.'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Đánh giá ${product.name}'),
        actions: [
          TextButton(
            onPressed: () => _openAddRating(context),
            child: const Text('Thêm đánh giá'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            product.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 6),
              Text('${product.rating} / 5 (${product.reviewCount} đánh giá)'),
            ],
          ),
          const SizedBox(height: 20),
          ...reviews.map(
            (review) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.divider),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.$1,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.$2 ? Icons.star : Icons.star_border,
                          size: 18,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(review.$3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
