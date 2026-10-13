---
name: flutter-apply-architecture-best-practices
description: Áp dụng kiến trúc Feature-First Clean Architecture kết hợp BLoC cho dự án Flutter sports-store-mobile. Sử dụng khi thiết kế module mới, tái cấu trúc mã nguồn hoặc review kiến trúc.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Sun, 11 Oct 2026 16:10:00 GMT
---
# Kiến Trúc Chuẩn: Feature-First Clean Architecture + BLoC

## 1. Nguyên Tắc Cốt Lõi
- **Độc lập tính năng (Feature Isolation):** Mỗi feature là một domain độc lập, chứa trọn vẹn 3 tầng: `data`, `domain`, `presentation`. Giúp 5 lập trình viên làm việc song song không bị xung đột mã nguồn.
- **Quy tắc phụ thuộc một chiều (Dependency Rule):** `Presentation` -> phụ thuộc `Domain` <- được triển khai bởi `Data`. Domain không phụ thuộc vào bất kỳ framework hoặc thư viện ngoài nào (trừ Dart core / Functional error handling).
- **State Management:** Sử dụng **BLoC / Cubit** độc quyền (`flutter_bloc`). Không dùng `ChangeNotifier` làm ViewModel.

## 2. Cấu Trúc Thư Mục Chuẩn
```text
lib/
├── app/                  # Khởi tạo App, Routes, BLoC Observer toàn cục
├── core/                 # Thành phần dùng chung (Network, Theme, Constants, Utils, Common Widgets)
└── features/             # Danh sách các tính năng
    ├── auth/             # Xác thực, Token Cache
    ├── product/          # Danh sách, Lọc, Tìm kiếm, Chi tiết
    ├── cart/             # Giỏ hàng, Tính tiền VNĐ
    ├── checkout_order/   # Thanh toán COD/VNPAY, Đơn hàng
    ├── profile_address/  # Sổ địa chỉ 3 cấp VN, Profile
    ├── voucher/          # Mã giảm giá
    ├── review_rating/    # Đánh giá & Rating
    └── admin/            # Quản trị sản phẩm, danh mục, đơn hàng
```

## 3. Trách Nhiệm Từng Tầng Trong Mỗi Feature

### Tầng Presentation
- **Screens:** Chỉ chứa giao diện trực quan, lắng nghe state qua `BlocBuilder`, `BlocConsumer`, `BlocListener`.
- **Widgets:** Các UI components con của riêng màn hình đó. Nếu dài >100 dòng thì tách vào đây.
- **Bloc / Cubit:** Nhận `Event` từ UI, gọi `UseCase` từ tầng Domain, phát sinh `State` mới (Immutable).

### Tầng Domain
- **Entities:** Mô hình dữ liệu nghiệp vụ thuần túy.
- **Repositories (Interfaces):** Hợp đồng (Contract) trừu tượng định nghĩa các hàm cần thiết.
- **Use Cases:** Lớp thực thi một nghiệp vụ cụ thể (Ví dụ: `AddToCartUseCase`, `ApplyVoucherUseCase`).

### Tầng Data
- **Data Sources:** Gọi API trực tiếp qua `Dio` kết nối tới Backend Service (sử dụng hệ quản trị cơ sở dữ liệu **Microsoft SQL Server**) hoặc truy xuất cache nội bộ trên mobile qua SharedPreferences / Secure Storage.
- **Models:** Kế thừa Entities, có hàm chuyển đổi `fromJson` và `toJson`.
- **Repositories (Implementations):** Hiện thực hóa Interface từ Domain, chuyển đổi Model sang Entity, bắt lỗi `DioException` thành `Failure`.

## 4. Kiểm Thử (Testing Rule)
- **BLoC Unit Test:** Bắt buộc viết test bằng `bloc_test` cho mọi BLoC/Cubit.
- **Data/Domain Test:** Giả lập Repository/DataSource bằng `mocktail`.
