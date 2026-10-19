import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final Dio dio;

  CategoryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await dio.get(ApiEndpoints.categories);

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data is Map<String, dynamic>
            ? (data['data'] as List<dynamic>? ?? data['items'] as List<dynamic>? ?? [])
            : (data as List<dynamic>? ?? []);

        return items
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: 'Lỗi máy chủ: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException {
      // Khi Backend chưa online trong giai đoạn phát triển,
      // fallback về mock dataset ngành hàng thể thao chuẩn Adidas DNA
      return _getMockCategories();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  /// Mock dataset các ngành hàng thể thao chuẩn thiết kế
  List<CategoryModel> _getMockCategories() {
    return const [
      CategoryModel(
        id: 'cat_shoes',
        name: 'Giày thể thao',
        imageUrl:
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=700&auto=format&fit=crop&q=80',
        description: 'Giày chạy bộ, bóng rổ, training trợ lực đỉnh cao.',
        itemCount: 24,
      ),
      CategoryModel(
        id: 'cat_tops',
        name: 'Áo thể thao',
        imageUrl:
            'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=700&auto=format&fit=crop&q=80',
        description: 'Áo thun thoáng khí, áo khoác gió, áo thi đấu chính hãng.',
        itemCount: 18,
      ),
      CategoryModel(
        id: 'cat_bottoms',
        name: 'Quần thể thao',
        imageUrl:
            'https://images.unsplash.com/photo-1517438476312-10d79c077509?w=700&auto=format&fit=crop&q=80',
        description: 'Quần shorts chạy bộ, quần jogger co giãn 4 chiều.',
        itemCount: 16,
      ),
      CategoryModel(
        id: 'cat_accessories',
        name: 'Phụ kiện thể thao',
        imageUrl:
            'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=700&auto=format&fit=crop&q=80',
        description: 'Balo chống nước, tất khử mùi, mũ lưỡi trai và bình nước.',
        itemCount: 32,
      ),
      CategoryModel(
        id: 'cat_gear',
        name: 'Dụng cụ tập luyện',
        imageUrl:
            'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=700&auto=format&fit=crop&q=80',
        description: 'Thảm yoga bám sàn, dây kháng lực, tạ tay và băng quấn.',
        itemCount: 14,
      ),
      CategoryModel(
        id: 'cat_protection',
        name: 'Đồ bảo hộ & Hỗ trợ',
        imageUrl:
            'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=700&auto=format&fit=crop&q=80',
        description: 'Băng bảo vệ khớp gối, cổ tay, mắt cá hạn chế chấn thương.',
        itemCount: 10,
      ),
    ];
  }
}

