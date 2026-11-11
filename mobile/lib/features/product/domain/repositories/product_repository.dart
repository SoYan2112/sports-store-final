import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({
    int page = 1,
    int size = 10,
    String? categoryId,
    String? keyword,
  });

  Future<ProductEntity> getProductById(String id);
  Future<void> addProductRating({
    required String productId,
    required String userId,
    required String userName,
    required int rating,
    String? comment,
  });

  Future<List<Map<String, dynamic>>> getProductRatings(String productId);
}
