import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRatingScreen extends StatefulWidget {
  final ProductEntity product;
  final String userId;
  final String userName;
  const ProductRatingScreen({
    super.key,
    required this.product,
    required this.userId,
    required this.userName,
  });
  @override
  State<ProductRatingScreen> createState() => _ProductRatingScreenState();
}

class _ProductRatingScreenState extends State<ProductRatingScreen> {
  int rating = 0;
  bool submitting = false;
  final content = TextEditingController();
  @override
  void dispose() {
    content.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (rating == 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Vui lòng chọn số sao')));
      return;
    }
    setState(() => submitting = true);
    try {
      await getIt<ProductRepository>().addProductRating(
        productId: widget.product.id,
        userId: widget.userId,
        userName: widget.userName,
        rating: rating,
        comment: content.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gửi đánh giá thất bại: $e')));
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Đánh giá ${widget.product.name}')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          widget.product.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        const Center(child: Text('Bạn đánh giá sản phẩm này thế nào?')),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (i) => IconButton(
              key: Key('ratingStar_${i + 1}'),
              iconSize: 42,
              icon: Icon(
                i < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () => setState(() => rating = i + 1),
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: content,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Nội dung đánh giá',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: submitting ? null : submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: submitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Gửi đánh giá'),
          ),
        ),
      ],
    ),
  );
}
