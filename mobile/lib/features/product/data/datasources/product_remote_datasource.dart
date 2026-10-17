import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int size = 10,
    String? categoryId,
    String? keyword,
  });

  Future<ProductModel> getProductById(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int size = 10,
    String? categoryId,
    String? keyword,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (keyword != null) queryParams['keyword'] = keyword;

      final response = await dio.get(
        ApiEndpoints.products,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data is Map<String, dynamic>
            ? (data['data'] as List<dynamic>? ?? data['items'] as List<dynamic>? ?? [])
            : (data as List<dynamic>? ?? []);

        return items
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: 'Lỗi máy chủ: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException {
      // Khi Backend chưa khởi chạy hoặc mất mạng trong giai đoạn phát triển,
      // fallback về mock dataset thể thao tươi sáng chất lượng cao để UI hiển thị và test mượt mà
      return _getMockProducts(page: page, size: size, keyword: keyword);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await dio.get('${ApiEndpoints.products}/$id');

      if (response.statusCode == 200) {
        final data = response.data;
        final Map<String, dynamic> item = data is Map<String, dynamic>
            ? (data['data'] as Map<String, dynamic>? ?? data)
            : <String, dynamic>{};

        return ProductModel.fromJson(item);
      } else {
        throw ServerException(
          message: 'Lỗi máy chủ: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException {
      // Khi Backend chưa online, fallback mock chi tiết sản phẩm
      return _getMockProductDetail(id);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  /// Mock data cho giai đoạn phát triển khi backend chưa kết nối
  List<ProductModel> _getMockProducts({
    required int page,
    required int size,
    String? keyword,
  }) {
    final allMock = [
      const ProductModel(
        id: 'p1',
        name: 'Nike unveil joyride',
        brand: 'Nike',
        price: 1950000,
        originalPrice: 2450000,
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&auto=format&fit=crop&q=80',
        badge: 'Hot',
        rating: 4.9,
        reviewCount: 128,
        description: 'Giày chạy bộ cao cấp với hạt đệm Joyride êm ái, trợ lực tối đa.',
      ),
      const ProductModel(
        id: 'p2',
        name: 'React Infinity Run Flyknit',
        brand: 'Nike',
        price: 2350000,
        originalPrice: 2800000,
        imageUrl: 'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=600&auto=format&fit=crop&q=80',
        badge: 'New',
        rating: 4.8,
        reviewCount: 95,
        description: 'Thiết kế giúp hạn chế chấn thương, đệm React êm ái và bám đường.',
      ),
      const ProductModel(
        id: 'p3',
        name: 'Nike Dunk High Retro',
        brand: 'Nike',
        price: 2990000,
        originalPrice: null,
        imageUrl: 'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=600&auto=format&fit=crop&q=80',
        badge: 'Best Seller',
        rating: 5.0,
        reviewCount: 210,
        description: 'Phong cách bóng rổ cổ điển những năm 80, thiết kế cổ cao sành điệu.',
      ),
      const ProductModel(
        id: 'p4',
        name: 'Adidas Ultraboost Light',
        brand: 'Adidas',
        price: 3200000,
        originalPrice: 4200000,
        imageUrl: 'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=600&auto=format&fit=crop&q=80',
        badge: 'Sale -24%',
        rating: 4.9,
        reviewCount: 164,
        description: 'Đệm Light BOOST nhẹ nhất từ trước đến nay, hoàn trả năng lượng vượt trội.',
      ),
      const ProductModel(
        id: 'p5',
        name: 'Puma Velocity Nitro 2',
        brand: 'Puma',
        price: 1850000,
        originalPrice: 2200000,
        imageUrl: 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600&auto=format&fit=crop&q=80',
        badge: 'New',
        rating: 4.7,
        reviewCount: 42,
        description: 'Đệm bọt Nitro siêu nhạy và đế ngoài Pumagrip bám mọi bề mặt.',
      ),
      const ProductModel(
        id: 'p6',
        name: 'Under Armour HOVR Phantom 3',
        brand: 'Under Armour',
        price: 2650000,
        originalPrice: null,
        imageUrl: 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600&auto=format&fit=crop&q=80',
        badge: 'Hot',
        rating: 4.8,
        reviewCount: 88,
        description: 'Công nghệ UA HOVR giảm lực va chạm, đàn hồi năng lượng trên từng bước chạy.',
      ),
      const ProductModel(
        id: 'p7',
        name: 'Reebok Club C 85 Vintage',
        brand: 'Reebok',
        price: 1450000,
        originalPrice: 1900000,
        imageUrl: 'https://images.unsplash.com/photo-1515955656352-a1fa3ffcd111?w=600&auto=format&fit=crop&q=80',
        badge: 'Sale -23%',
        rating: 4.6,
        reviewCount: 75,
        description: 'Phong cách quần vợt cổ điển với da mềm mại và đế lót êm ái.',
      ),
      const ProductModel(
        id: 'p8',
        name: 'Nike Air Zoom Pegasus 40',
        brand: 'Nike',
        price: 2790000,
        originalPrice: 3200000,
        imageUrl: 'https://images.unsplash.com/photo-1575537302964-96cd47c06b1b?w=600&auto=format&fit=crop&q=80',
        badge: 'Best Seller',
        rating: 4.9,
        reviewCount: 320,
        description: 'Biểu tượng chạy bộ 40 năm với túi khí đôi Zoom Air trước và sau.',
      ),
    ];

    final filtered = (keyword == null || keyword.trim().isEmpty)
        ? allMock
        : allMock.where((p) {
            final q = keyword.trim().toLowerCase();
            return p.name.toLowerCase().contains(q) ||
                p.brand.toLowerCase().contains(q) ||
                p.category.toLowerCase().contains(q);
          }).toList();

    final startIndex = (page - 1) * size;
    if (startIndex >= filtered.length) {
      return [];
    }
    final endIndex = (startIndex + size > filtered.length) ? filtered.length : startIndex + size;
    return filtered.sublist(startIndex, endIndex);
  }

  ProductModel _getMockProductDetail(String id) {
    final list = _getMockProducts(page: 1, size: 50);
    final found = list.firstWhere(
      (p) => p.id == id,
      orElse: () => list.isNotEmpty
          ? list.first
          : const ProductModel(
              id: 'p1',
              name: 'Nike unveil joyride',
              brand: 'Nike',
              price: 1950000,
              originalPrice: 2450000,
              imageUrl:
                  'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&auto=format&fit=crop&q=80',
              badge: 'Hot',
            ),
    );

    // Gallery ảnh phong phú cho từng góc nhìn sản phẩm
    final gallery = [
      found.imageUrl,
      'https://images.unsplash.com/photo-1514989940723-e8e51635b782?w=600&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=600&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=600&auto=format&fit=crop&q=80',
    ];

    return ProductModel(
      id: found.id,
      name: found.name,
      brand: found.brand,
      price: found.price,
      originalPrice: found.originalPrice,
      imageUrl: found.imageUrl,
      badge: found.badge,
      rating: found.rating,
      reviewCount: found.reviewCount > 0 ? found.reviewCount : 128,
      description: found.description.isNotEmpty
          ? '${found.description}\n\nĐược chế tác từ các vật liệu tái chế bền vững, công nghệ đệm hỗ trợ đàn hồi cao giúp bảo vệ cổ chân và trợ lực trong từng sải bước. Thích hợp cho cả tập luyện thể thao cường độ cao lẫn hoạt động phong cách hàng ngày.'
          : 'Sản phẩm thể thao cao cấp chính hãng, hỗ trợ vận động tối ưu và đệm khí êm ái suốt ngày dài.',
      images: gallery,
      category: 'Giày chạy bộ & Thể thao',
      stock: 12,
      sizes: const ['38', '39', '40', '41', '42', '43'],
      colors: const [
        0xFF1A1A1A, // Đen thể thao
        0xFFFFFFFF, // Trắng tinh tế
        0xFFFF6B00, // Cam rực rỡ (Accent)
        0xFF1E88E5, // Xanh dương thể thao
      ],
    );
  }
}
