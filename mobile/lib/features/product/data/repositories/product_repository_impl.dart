import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProductEntity>> getProducts({
    int page = 1,
    int size = 10,
    String? categoryId,
    String? keyword,
  }) async {
    return await remoteDataSource.getProducts(
      page: page,
      size: size,
      categoryId: categoryId,
      keyword: keyword,
    );
  }
}
