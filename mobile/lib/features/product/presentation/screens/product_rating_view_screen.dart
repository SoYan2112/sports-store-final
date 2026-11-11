import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_rating_screen.dart';

class ProductRatingViewScreen extends StatefulWidget {
  final ProductEntity product;
  const ProductRatingViewScreen({super.key, required this.product});

  @override
  State<ProductRatingViewScreen> createState() => _ProductRatingViewScreenState();
}

class _ProductRatingViewScreenState extends State<ProductRatingViewScreen> {
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await getIt<ProductRepository>().getProductRatings(widget.product.id);
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openAddRating() async {
    final user = getIt<LocalStorageService>().getSavedUser();
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductRatingScreen(
          product: widget.product,
          userId: user?['id'] ?? 'guest',
          userName: user?['name'] ?? 'Khách hàng',
        ),
      ),
    );
    if (saved == true) _loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đánh giá ${widget.product.name}'),
        actions: [
          TextButton(onPressed: _openAddRating, child: const Text('Thêm đánh giá')),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReviews,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(widget.product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text('${widget.product.rating} / 5 (${_reviews.length} đánh giá)'),
                  ]),
                  const SizedBox(height: 20),
                  if (_reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text('Chưa có đánh giá nào.')),
                    )
                  else
                    ..._reviews.map(_buildReviewCard),
                ],
              ),
            ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = (review['rating'] as num?)?.toInt() ?? 0;
    final userName = review['user_name']?.toString() ?? 'Khách hàng';
    final comment = review['comment']?.toString() ?? '';
    return Card(
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
            Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: List.generate(5, (index) => Icon(
                index < rating ? Icons.star : Icons.star_border,
                size: 18,
                color: Colors.amber,
              )),
            ),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(comment),
            ],
          ],
        ),
      ),
    );
  }
}
