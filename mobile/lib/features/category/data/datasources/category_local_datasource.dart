import '../../../../core/database/app_database.dart';
import '../models/category_model.dart';
import 'category_remote_datasource.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoryLocalDataSourceImpl
    implements CategoryLocalDataSource, CategoryRemoteDataSource {
  final AppDatabase appDatabase;

  CategoryLocalDataSourceImpl({AppDatabase? appDatabase})
      : appDatabase = appDatabase ?? AppDatabase.instance;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final db = await appDatabase.database;
    final results = await db.query('categories');
    return results.map((row) {
      return CategoryModel(
        id: row['id'] as String,
        name: row['name'] as String,
        imageUrl: row['image_url'] as String? ?? '',
        description: row['description'] as String? ?? '',
        itemCount: (row['item_count'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }
}
