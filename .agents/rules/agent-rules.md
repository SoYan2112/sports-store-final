---
trigger: always_on
---

# QUY TẮC LÀM VIỆC VÀ KIẾN TRÚC DỰ ÁN (FLUTTER) - SPORTS STORE MOBILE

Tài liệu này quy định các chuẩn mực cốt lõi (Core Rules) mà AI và mọi thành viên bắt buộc phải tuân thủ trong suốt vòng đời dự án `sports-store-mobile`. Các quy trình chức năng chuyên sâu đã được tách sang thư mục `.agents/skills/`.

## 1. Công Nghệ Cốt Lõi (Tech Stack)
- **Framework:** Flutter (Dart >= 3.x)
- **State Management:** BẮT BUỘC sử dụng `flutter_bloc` & `cubit` (quản lý state tách biệt Event - State).
- **Mạng & Gọi API:** Sử dụng `dio` kèm Interceptors.
- **Dependency Injection:** Sử dụng `get_it` kết hợp `injectable`.
- **Local Storage:** `shared_preferences` (Cache, Theme) & `flutter_secure_storage` (Token).

## 2. Kiến Trúc Thư Mục (Feature-First Clean Architecture)
Tuyệt đối không để lẫn lộn các tầng (layer) với nhau. Mọi tính năng phải nằm trong thư mục `lib/features/`:

```text
lib/
├── app/
│   ├── app.dart                   # MaterialApp cấu hình routes, theme, bloc providers
│   ├── app_bloc_observer.dart     # Logger theo dõi toàn bộ state transitions
│   └── routes/                    # GoRouter hoặc AutoRoute định tuyến màn hình
├── core/
│   ├── constants/                 # Màu sắc, font chữ, asset paths, API endpoints
│   ├── errors/                    # Exception & Failure classes
│   ├── network/                   # Dio client setup, interceptors, error handler
│   ├── theme/                     # Adidas dark/light theme, typography
│   ├── utils/                     # Format tiền tệ VNĐ, ngày tháng, validate SĐT
│   └── widgets/                   # Common UI: AppButton, AppTextField, LoadingDialog
├── features/
│   ├── auth/                      # Đăng nhập, đăng ký, quên mật khẩu, token cache
│   │   ├── data/ (models, datasources, repositories)
│   │   ├── domain/ (entities, repository_interfaces, usecases)
│   │   └── presentation/ (bloc, screens, widgets)
│   ├── product/                   # Danh sách sản phẩm, lọc, tìm kiếm, chi tiết
│   ├── cart/                      # Giỏ hàng, tính tổng tiền, số lượng
│   ├── checkout_order/            # Thanh toán (COD/VNPAY), lịch sử đơn hàng
│   ├── profile_address/           # Thông tin cá nhân, sổ địa chỉ 3 cấp VN
│   ├── review_rating/             # Đánh giá sao, viết nhận xét sản phẩm
│   ├── voucher/                   # Quản lý voucher, áp dụng mã giảm giá
│   └── admin/                     # Quản lý sản phẩm, danh mục, duyệt đơn hàng
└── main.dart                      # Điểm khởi chạy ứng dụng
```

## 3. Quy Định Thiết Kế Giao Diện (Adidas DNA & Tiêu Chuẩn VN)
- **Phong Cách:** Giao diện tối giản, thể thao. Tông màu: Đen tuyền (`#000000`), Trắng (`#FFFFFF`), Xám (`#767677`) và màu highlight (Neon).
- **Typography:** Sử dụng Font không chân, nét đậm, vuông vức (Oswald, Montserrat).
- **Format Tiền Tệ VNĐ:** Bắt buộc định dạng theo kiểu Việt Nam: `1.950.000 ₫` (dấu chấm phân cách ngàn).
- **Số Điện Thoại:** Validate đúng định dạng Việt Nam (`+84`, `09x`, `03x`...).

## 4. Quy Tắc Đặt Tên (Naming Conventions)
- **File & Thư mục:** `snake_case` (vd: `cart_bloc.dart`).
- **Class, Enum:** `PascalCase` (vd: `ProductDetailScreen`).
- **Biến & Hàm:** `camelCase` (vd: `fetchProductList()`).