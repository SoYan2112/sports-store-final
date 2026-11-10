import 'dart:convert';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/product_model.dart';
import 'product_remote_datasource.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int size = 10,
    String? categoryId,
    String? keyword,
  });

  Future<ProductModel> getProductById(String id);

  Future<void> addProductRating({
    required String productId,
    required String userId,
    required String userName,
    required int rating,
    String? comment,
  });

  Future<List<Map<String, dynamic>>> getProductRatings(String productId);
}

class ProductLocalDataSourceImpl
    implements ProductLocalDataSource, ProductRemoteDataSource {
  final AppDatabase appDatabase;

  ProductLocalDataSourceImpl({AppDatabase? appDatabase})
      : appDatabase = appDatabase ?? AppDatabase.instance;

  ProductModel _mapRowToProduct(Map<String, dynamic> row) {
    List<String> images = [];
    if (row['images_json'] != null) {
      try {
        images = (jsonDecode(row['images_json'] as String) as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      } catch (_) {}
    }
    if (images.isEmpty && row['image_url'] != null) {
      images = [row['image_url'] as String];
    }

    List<String> sizes = const ['38', '39', '40', '41', '42', '43'];
    if (row['sizes_json'] != null) {
      try {
        sizes = (jsonDecode(row['sizes_json'] as String) as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      } catch (_) {}
    }

    List<int> colors = const [0xFF1A1A1A, 0xFFFFFFFF, 0xFFFF6B00];
    if (row['colors_json'] != null) {
      try {
        colors = (jsonDecode(row['colors_json'] as String) as List<dynamic>)
            .map((e) => (e as num).toInt())
            .toList();
      } catch (_) {}
    }

    return ProductModel(
      id: row['id'] as String,
      name: row['name'] as String,
      brand: row['brand'] as String? ?? 'Nike',
      price: (row['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (row['original_price'] as num?)?.toDouble(),
      imageUrl: row['image_url'] as String? ?? '',
      badge: row['badge'] as String?,
      rating: (row['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (row['review_count'] as num?)?.toInt() ?? 0,
      description: row['description'] as String? ?? '',
      images: images,
      category: row['category'] as String? ?? 'Giày thể thao',
      stock: (row['stock'] as num?)?.toInt() ?? 15,
      sizes: sizes,
      colors: colors,
    );
  }

  @override
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int size = 10,
    String? categoryId,
    String? keyword,
  }) async {
    final db = await appDatabase.database;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (categoryId != null && categoryId.isNotEmpty) {
      whereClauses.add('(category_id = ? OR category = ?)');
      whereArgs.add(categoryId);
      whereArgs.add(categoryId);
    }

    if (keyword != null && keyword.trim().isNotEmpty) {
      final term = '%${keyword.trim().toLowerCase()}%';
      whereClauses.add('(LOWER(name) LIKE ? OR LOWER(brand) LIKE ?)');
      whereArgs.add(term);
      whereArgs.add(term);
    }

    final whereString =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;
    final offset = (page - 1) * size;

    final results = await db.query(
      'products',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      limit: size,
      offset: offset,
      orderBy: 'id ASC',
    );

    return results.map(_mapRowToProduct).toList();
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    final db = await appDatabase.database;
    final results = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) {
      throw ServerException(message: 'Không tìm thấy sản phẩm có mã $id');
    }

    return _mapRowToProduct(results.first);
  }

  @override
  Future<void> addProductRating({
    required String productId,
    required String userId,
    required String userName,
    required int rating,
    String? comment,
  }) async {
    final db = await appDatabase.database;
    final ratingId = 'rate_${DateTime.now().millisecondsSinceEpoch}';

    // 1. Thêm bản ghi rating vào SQLite
    await db.insert('product_ratings', {
      'id': ratingId,
      'product_id': productId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'created_at': DateTime.now().toIso8601String(),
    });

    // 2. Cập nhật lại reviewCount & rating trung bình trong bảng products
    final ratings = await db.query(
      'product_ratings',
      where: 'product_id = ?',
      whereArgs: [productId],
    );

    final totalReviews = ratings.length;
    final double avgRating = ratings.fold<double>(
          0.0,
          (sum, r) => sum + ((r['rating'] as num?)?.toDouble() ?? 5.0),
        ) /
        totalReviews;

    await db.update(
      'products',
      {
        'rating': double.parse(avgRating.toStringAsFixed(1)),
        'review_count': totalReviews,
      },
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getProductRatings(String productId) async {
    final db = await appDatabase.database;
    return await db.query(
      'product_ratings',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'created_at DESC',
    );
  }
}
