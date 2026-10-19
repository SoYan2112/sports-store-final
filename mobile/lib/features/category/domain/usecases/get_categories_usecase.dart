import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;

  const GetCategoriesUseCase(this.repository);

  Future<List<CategoryEntity>> call() async {
    return await repository.getCategories();
  }
}

