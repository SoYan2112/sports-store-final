# Kiến Trúc & Chuẩn Kỹ Thuật (Architecture & Skills Alignment)
## Dự án: sports-store-mobile

---

### 1. Cấu trúc Feature-First Clean Architecture

Mỗi `feature/` được tổ chức theo 3 tầng:

```
features/
└── {feature_name}/
    ├── data/
    │   ├── models/           # JSON models (freezed + json_serializable)
    │   ├── datasources/      # RemoteDataSource (Dio API calls)
    │   └── repositories/     # Repository implementation
    ├── domain/
    │   ├── entities/         # Pure Dart entities (business objects)
    │   ├── repositories/     # Abstract repository interfaces
    │   └── usecases/         # Single-responsibility use case classes
    └── presentation/
        ├── bloc/             # BLoC / Cubit + Events + States
        ├── screens/          # Full-page Screen widgets
        └── widgets/          # Reusable sub-widgets trong feature
```

---

### 2. Quy ước đặt tên (Naming Conventions)

| Loại | Convention | Ví dụ |
|:---|:---:|:---|
| File & Thư mục | `snake_case` | `auth_bloc.dart`, `product_card.dart` |
| Class, Enum | `PascalCase` | `AuthBloc`, `ProductDetailScreen` |
| Biến & Hàm | `camelCase` | `fetchProductList()`, `selectedSize` |
| BLoC Event | `PascalCase` + `Event` | `LoginEvent`, `AddToCartEvent` |
| BLoC State | `PascalCase` + `State` | `AuthLoading`, `CartLoaded` |
| Cubit method | `camelCase` | `selectSize()`, `applyVoucher()` |

---

### 3. Dependency Injection với get_it + injectable

```dart
// core/injection/injection.dart
@InjectableInit()
void configureDependencies() => getIt.init();

// Sử dụng trong BLoC
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository) : super(AuthInitial());
  final AuthRepository _authRepository;
}
```

---

### 4. Network Layer — Dio Interceptors

```dart
// core/network/dio_client.dart
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    _dio.interceptors.addAll([
      AuthInterceptor(),      // Tự động gắn Bearer Token
      RefreshTokenInterceptor(), // Tự động làm mới token khi 401
      LogInterceptor(),       // Log request/response cho debug
    ]);
  }
}
```

---

### 5. State Management — BLoC Pattern

```dart
// Cấu trúc chuẩn của một BLoC
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc(this._productRepository) : super(ProductInitial()) {
    on<FetchProductsEvent>(_onFetchProducts);
    on<FetchMoreProductsEvent>(_onFetchMore);
    on<ApplyFilterEvent>(_onApplyFilter);
  }

  Future<void> _onFetchProducts(
    FetchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final result = await _productRepository.getProducts(page: 1);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductLoaded(products: products)),
    );
  }
}
```

---

### 6. Format Tiền Tệ VNĐ (bắt buộc toàn dự án)

```dart
// core/utils/currency_formatter.dart
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatVND(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount).replaceAll(',', '.')} ₫';
  }
}

// Sử dụng: CurrencyFormatter.formatVND(1950000) → "1.950.000 ₫"
```

---

### 7. Validate Số Điện Thoại Việt Nam

```dart
// core/utils/validators.dart
class Validators {
  static bool isValidVietnamesePhone(String phone) {
    final regex = RegExp(r'^(0|\+84)(3|5|7|8|9)\d{8}$');
    return regex.hasMatch(phone.trim());
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }
}
```

---

### 8. Thứ tự Ưu tiên Cài đặt Dependency (pubspec.yaml)

```yaml
dependencies:
  flutter_bloc: ^8.x.x       # State Management
  dio: ^5.x.x                # HTTP Client
  get_it: ^7.x.x             # Service Locator
  injectable: ^2.x.x         # Code generation cho DI
  shared_preferences: ^2.x.x # Local storage (token, theme)
  flutter_secure_storage: ^9.x.x # Secure storage (credentials)
  freezed_annotation: ^2.x.x # Immutable models
  json_annotation: ^4.x.x    # JSON serialization
  cached_network_image: ^3.x.x # Image caching
  intl: ^0.19.x              # Internationalization (VNĐ format)
  go_router: ^14.x.x         # Navigation & routing

dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.x.x          # BLoC unit testing
  mocktail: ^1.x.x           # Mock dependencies
  freezed: ^2.x.x            # Code generation
  json_serializable: ^6.x.x  # JSON code generation
  injectable_generator: ^2.x.x # DI code generation
  build_runner: ^2.x.x       # Build runner
```
