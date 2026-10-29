import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/voucher_entity.dart';
import '../models/voucher_model.dart';

abstract class VoucherRemoteDataSource {
  Future<List<VoucherModel>> getVouchers();
}

class VoucherRemoteDataSourceImpl implements VoucherRemoteDataSource {
  final Dio dio;

  VoucherRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<VoucherModel>> getVouchers() async {
    try {
      final response = await dio.get(ApiEndpoints.vouchers);

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> items = data is Map<String, dynamic>
            ? (data['data'] as List<dynamic>? ?? data['items'] as List<dynamic>? ?? [])
            : (data as List<dynamic>? ?? []);

        return items
            .map((item) => VoucherModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: 'Lỗi máy chủ khi lấy danh sách voucher: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException {
      // Khi backend chưa sẵn sàng, trả về dữ liệu mock thể thao đầy đủ
      return _getMockVouchers();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  /// Mock danh sách voucher ưu đãi dành riêng cho Sports Store
  List<VoucherModel> _getMockVouchers() {
    final now = DateTime.now();

    return [
      VoucherModel(
        id: 'v_summer20',
        code: 'SUMMER20',
        title: 'Giảm 20% đơn từ 400k',
        description: 'Áp dụng cho mọi đơn hàng. Giảm tối đa 100.000 ₫.',
        type: VoucherType.percentage,
        discountValue: 20,
        minOrderValue: 400000,
        maxDiscountAmount: 100000,
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 15)),
        isUsed: false,
      ),
      VoucherModel(
        id: 'v_freeship',
        code: 'FREESHIP',
        title: 'Miễn phí vận chuyển toàn quốc',
        description: 'Freeship Extra tối đa 35.000 ₫ cho mọi đơn hàng từ 300.000 ₫.',
        type: VoucherType.freeShipping,
        discountValue: 35000,
        minOrderValue: 300000,
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 25)),
        isUsed: false,
      ),
      VoucherModel(
        id: 'v_sport100',
        code: 'SPORT100',
        title: 'Giảm trực tiếp 100.000 ₫',
        description: 'Áp dụng cho đơn hàng từ 1.200.000 ₫.',
        type: VoucherType.fixedAmount,
        discountValue: 100000,
        minOrderValue: 1200000,
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 10)),
        isUsed: false,
      ),
      VoucherModel(
        id: 'v_sale50',
        code: 'SALE50',
        title: 'Giảm 50.000 ₫ đơn từ 600k',
        description: 'Áp dụng cho mọi đơn hàng từ 600.000 ₫.',
        type: VoucherType.fixedAmount,
        discountValue: 50000,
        minOrderValue: 600000,
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 20)),
        isUsed: false,
      ),
    ];
  }
}

