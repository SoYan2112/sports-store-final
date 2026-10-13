import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<ProductEntity>> call({
    int page = 1,
    int size = 10,
    String? categoryId,
    String? keyword,
  }) {
    return repository.getProducts(
      page: page,
      size: size,
      categoryId: categoryId,
      keyword: keyword,
    );
  }
}
