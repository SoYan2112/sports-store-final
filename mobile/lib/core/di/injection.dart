import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../../features/auth/data/datasources/auth_service.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository_interface.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/cubit/register_cubit.dart';
import '../../features/product/data/datasources/product_remote_datasource.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/get_product_detail_usecase.dart';
import '../../features/product/domain/usecases/get_products_usecase.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/local_storage_service.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/category/data/datasources/category_remote_datasource.dart';
import '../../features/category/data/repositories/category_repository_impl.dart';
import '../../features/category/domain/repositories/category_repository.dart';
import '../../features/category/domain/usecases/get_categories_usecase.dart';
import '../../features/category/presentation/cubit/category_cubit.dart';
import '../../features/product/presentation/cubit/product_detail_cubit.dart';
import '../../features/product/presentation/cubit/search_cubit.dart';
import '../../features/product/presentation/cubit/filter_cubit.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Storage
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(getIt<SharedPreferences>()),
  );

  // Network
  getIt.registerLazySingleton<DioClient>(() => DioClient());
  getIt.registerLazySingleton<Dio>(() => getIt<DioClient>().dio);

  // Features - Auth
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(authService: getIt<AuthService>()),
  );
  getIt.registerLazySingleton<AuthRepositoryInterface>(
    () => getIt<AuthRepository>(),
  );
  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(getIt<AuthRepositoryInterface>()),
  );
  getIt.registerFactory<RegisterCubit>(
    () => RegisterCubit(registerUseCase: getIt<RegisterUseCase>()),
  );
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      storageService: getIt<LocalStorageService>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );

  // Features - Category Data Source & Repository
  getIt.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(dio: getIt<Dio>()),
  );
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(remoteDataSource: getIt<CategoryRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(getIt<CategoryRepository>()),
  );
  getIt.registerFactory<CategoryCubit>(
    () => CategoryCubit(getCategoriesUseCase: getIt<GetCategoriesUseCase>()),
  );

  // Features - Product Data Source
  getIt.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Features - Product Repository
  getIt.registerLazySingleton<ProductRepository>( () => ProductRepositoryImpl(remoteDataSource: getIt<ProductRemoteDataSource>()),
  );

  // Features - Product Use Cases
  getIt.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(getIt<ProductRepository>()),
  );
  getIt.registerLazySingleton<GetProductDetailUseCase>(
    () => GetProductDetailUseCase(getIt<ProductRepository>()),
  );

  // Features - Product Bloc & Cubit
  getIt.registerFactory<ProductBloc>(
    () => ProductBloc(getProductsUseCase: getIt<GetProductsUseCase>()),
  );
  getIt.registerFactory<ProductDetailCubit>(
    () => ProductDetailCubit(
      getProductDetailUseCase: getIt<GetProductDetailUseCase>(),
    ),
  );
  getIt.registerFactory<SearchCubit>(
    () => SearchCubit(getProductsUseCase: getIt<GetProductsUseCase>()),
  );
  getIt.registerLazySingleton<FilterCubit>(
    () => FilterCubit(),
  );
}