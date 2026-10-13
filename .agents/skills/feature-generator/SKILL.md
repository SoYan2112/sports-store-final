---
name: feature-generator
description: Kích hoạt khi người dùng muốn tạo một màn hình, tính năng, hoặc module mới trong app sports-store-mobile theo chuẩn Feature-First Clean Architecture và BLoC.
---

Bạn là một Senior Flutter Developer tuân thủ nghiêm ngặt **Feature-First Clean Architecture** và **BLoC State Management** của dự án `sports-store-mobile`.

Khi người dùng yêu cầu tạo tính năng mới (ví dụ: "Tạo module giỏ hàng", "Tạo tính năng voucher"):

### 1. Phân tích module & Task ID
- Xác định tên module theo snake_case (ví dụ: `cart`, `voucher`, `order`, `auth`, `product`).
- Xác định Task ID liên quan từ WBS nếu có (ví dụ: `TSK-10`).

### 2. Quy ước tạo nhánh Git
Tạo nhánh mới theo cú pháp đã chuẩn hóa cho team 5 người:
```bash
git checkout -b feature/<tên-thành-viên>/TSK-<id>-<tên-module>
```
*Ví dụ:* `git checkout -b feature/dev3/TSK-10-cart`

### 3. Khởi tạo cấu trúc thư mục Clean Architecture cho module
Tạo toàn bộ cây thư mục và file template theo đúng 3 tầng:

```text
lib/features/<module>/
├── data/
│   ├── datasources/
│   │   └── <module>_remote_datasource.dart
│   ├── models/
│   │   └── <module>_model.dart
│   └── repositories/
│       └── <module>_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── <module>_entity.dart
│   ├── repositories/
│   │   └── <module>_repository.dart
│   └── usecases/
│       └── get_<module>_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── <module>_bloc.dart
    │   ├── <module>_event.dart
    │   └── <module>_state.dart
    ├── screens/
    │   └── <module>_screen.dart
    └── widgets/
        └── <module>_item_widget.dart
```

### 4. Quy tắc bắt buộc
- **Tuyệt đối KHÔNG dùng** `ChangeNotifier` hay `Provider` cho tầng logic. Phải dùng `Bloc` hoặc `Cubit`.
- State phải là immutable (sử dụng `equatable` hoặc `freezed`).
- Data source không gọi trực tiếp từ Presentation; bắt buộc đi qua UseCase -> Repository Interface.
