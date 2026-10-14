# Phân Công Nhiệm Vụ 5 Thành Viên (Team Assignment & Workload Matrix)
## Dự án: sports-store-mobile (Multi-brand Sports Store)

Phân công theo mô hình **Feature / Domain Owner**: Mỗi thành viên chịu trách nhiệm trọn vòng đời (End-to-End) cho các Use Cases được giao (UI Screen, BLoC/Cubit State Management, Repository/DataSource, kiểm thử Unit/Widget Test), đồng thời phối hợp Code Review chéo qua GitHub Pull Request.

---

### 📊 Bảng Ma Trận Khối Lượng Công Việc (Workload Matrix)

| Thành viên | Mã SV | Domain phụ trách chính | Danh sách Use Cases | Tổng số UC | Tổng Points | Tiến độ cá nhân |
| :--- | :---: | :--- | :--- | :---: | :---: | :---: |
| **Thái San Yo** | **CE190435** | **Home Layout, Catalog & Shopping Cart** | **UC-04, UC-07, UC-11, UC-12, UC-13, UC-23** | **6 UCs** | **7 pts** | ⏳ 1 Done, 2 In Progress, 3 Not Yet |
| **Nguyễn Hoài Ân** | **CE190990** | **Authentication, Checkout & Order History** | **UC-01, UC-08, UC-14, UC-15** | **4 UCs** | **8 pts** | ⏳ 1 Done, 3 Not Yet |
| **Trần Hoàng Nhật** | **CE190581** | **Registration & Shipping Address (3 Cấp VN)** | **UC-02, UC-10, UC-18, UC-19** | **4 UCs** | **7 pts** | ⏳ 1 Done, 1 In Progress, 2 Not Yet |
| **Nguyễn Minh Nhật**| **CE191491** | **Logout, Variants & Category Management** | **UC-03, UC-06, UC-16, UC-21, UC-22** | **5 UCs** | **8 pts** | ⏳ 2 Done, 3 Not Yet |
| **Ngô Nhất Quý** | **CE190984** | **Product Detail, Search, Filter & Cancel Order**| **UC-05, UC-09, UC-17, UC-20** | **4 UCs** | **8 pts** | ⏳ 1 Done, 3 Not Yet |
| **TỔNG CỘNG** | — | **5 Domain Owners** | **UC-01 → UC-23** | **23 UCs** | **38 pts** | **Tiến độ: 6/23 Done** |

---

### 📌 Phân Công Chi Tiết Theo Từng Thành Viên

#### 1. Thái San Yo (CE190435) — 6 UCs · 7 pts
- **UC-04 · View product list** (`P0` · Simple · 1 pt · Sprint 1): Grid 2 cột, Shimmer Skeleton, BLoC Infinite Scroll. (✅ **Done**)
- **UC-07 · Home layout** (`P1` · Simple · 1 pt · Sprint 1): `MainLayoutScreen` (BottomNavigationBar 4 tab), `HomeScreen` (Banner Carousel, Quick Category Chips, Featured Products) kết hợp cơ chế Lazy Login. (⏳ **In progress**)
- **UC-11 · Add product to cart** (`P0` · Medium · 2 pts · Sprint 2): Logic thêm sản phẩm cùng size/màu vào `CartBloc`, lưu trạng thái cục bộ và phản hồi SnackBar/Badge. (⏳ **In progress**)
- **UC-12 · View shopping cart** (`P0` · Simple · 1 pt · Sprint 2): `CartScreen`, danh sách item có ảnh, size, số lượng, tự động tính tổng tiền VNĐ. (⏹ Not yet)
- **UC-13 · Remove item from cart** (`P0` · Simple · 1 pt · Sprint 2): Thao tác vuốt xóa (Dismissible) hoặc nút thùng rác, dialog xác nhận xóa sản phẩm khỏi giỏ. (⏹ Not yet)
- **UC-23 · Remove product categories** (`P1` · Simple · 1 pt · Sprint 3): Chức năng xóa danh mục sản phẩm kèm kiểm tra ràng buộc sản phẩm tồn tại. (⏹ Not yet)

#### 2. Nguyễn Hoài Ân (CE190990) — 4 UCs · 8 pts
- **UC-01 · Login** (`P0` · Medium · 2 pts · Sprint 1): Màn hình `LoginScreen`, gọi API đăng nhập, lưu JWT vào `SharedPreferences`, nhánh `feat/login`. (✅ **Done**)
- **UC-08 · Order selected items in cart** (`P0` · Complex · 3 pts · Sprint 2): Màn hình xác nhận thanh toán (Checkout), chọn phương thức COD, gọi API tạo đơn hàng mới. (⏹ Not yet)
- **UC-14 · View order history** (`P0` · Simple · 1 pt · Sprint 2): Màn hình lịch sử đơn hàng, hiển thị danh sách đơn kèm trạng thái (Chờ xác nhận, Đang giao, Đã giao, Đã hủy). (⏹ Not yet)
- **UC-15 · View order details** (`P0` · Medium · 2 pts · Sprint 3): Xem chi tiết từng đơn hàng: mã đơn, ngày đặt, địa chỉ nhận hàng, phương thức thanh toán, danh sách món và tổng thanh toán. (⏹ Not yet)

#### 3. Trần Hoàng Nhật (CE190581) — 4 UCs · 7 pts
- **UC-02 · Register** (`P0` · Medium · 2 pts · Sprint 1): Màn hình `RegisterScreen`, validate SĐT Việt Nam (+84), mật khẩu, gọi API đăng ký, nhánh `feat/register`. (✅ **Done**)
- **UC-10 · Add shipping address** (`P1` · Medium · 2 pts · Sprint 2): Form thêm địa chỉ mới với danh mục hành chính 3 cấp Việt Nam (Tỉnh/Thành phố → Quận/Huyện → Phường/Xã). (⏳ **In progress**)
- **UC-18 · Edit shipping address** (`P1` · Medium · 2 pts · Sprint 3): Cập nhật thông tin địa chỉ đã lưu, đánh dấu địa chỉ mặc định. (⏹ Not yet)
- **UC-19 · Delete shipping address** (`P1` · Simple · 1 pt · Sprint 3): Xóa địa chỉ khỏi sổ địa chỉ người dùng kèm dialog xác nhận. (⏹ Not yet)

#### 4. Nguyễn Minh Nhật (CE191491) — 5 UCs · 8 pts
- **UC-03 · Logout** (`P0` · Simple · 1 pt · Sprint 1): Xóa token, reset navigation stack và state, nhánh `feat/logout`. (✅ **Done**)
- **UC-06 · Select product variant** (`P0` · Complex · 3 pts · Sprint 1): Bộ chọn Size (38-43) & Màu sắc động, kiểm tra tồn kho theo từng variant, cập nhật trạng thái mua. (✅ **Done**)
- **UC-16 · View product categories** (`P0` · Simple · 1 pt · Sprint 3): Màn hình hoặc drawer danh mục các dòng sản phẩm thể thao (Giày, Áo, Quần, Phụ kiện). (⏹ Not yet)
- **UC-21 · Add product categories** (`P1` · Simple · 1 pt · Sprint 3): Form thêm danh mục sản phẩm mới với tên, mã và ảnh đại diện. (⏹ Not yet)
- **UC-22 · Edit product categories** (`P1` · Medium · 2 pts · Sprint 3): Chỉnh sửa thông tin danh mục hiện có. (⏹ Not yet)

#### 5. Ngô Nhất Quý (CE190984) — 4 UCs · 8 pts
- **UC-05 · View product details** (`P0` · Medium · 2 pts · Sprint 1): `ProductDetailScreen` với Gallery ảnh đa góc nhìn, thông số kỹ thuật, mô tả và nút CTA "Add to cart". (✅ **Done**)
- **UC-09 · Search products by keyword** (`P1` · Simple · 1 pt · Sprint 2): `SearchScreen` với thanh tìm kiếm có debounce 500ms, gợi ý từ khóa và lịch sử tìm kiếm gần đây. (⏹ Not yet)
- **UC-17 · Filter products** (`P1` · Medium · 2 pts · Sprint 3): Bộ lọc nâng cao: khoảng giá (Price Range Slider), thương hiệu, xếp hạng sao, sắp xếp giá tăng/giảm. (⏹ Not yet)
- **UC-20 · Cancel order** (`P1` · Complex · 3 pts · Sprint 3): Nghiệp vụ hủy đơn hàng khi đơn ở trạng thái "Chờ xác nhận" (Pending), cập nhật lý do hủy và hoàn trả trạng thái tồn kho. (⏹ Not yet)

---

### 🌿 Quy Trình Git & Chuẩn Phối Hợp Làm Việc
1. **Quy tắc phân nhánh (Branching Convention)**:
   - Nhánh chính: `main` (Production), `develop` (Integration).
   - Nhánh tính năng: `feat/UC-[ID]-[short-name]` (VD: `feat/UC-07-home-layout`, `feat/UC-11-add-to-cart`).
2. **Quy tắc Code Review & Merge**:
   - Bắt buộc tạo Pull Request (PR) vào `develop`.
   - Có ít nhất 1 thành viên review và approve trước khi merge.
   - Chạy kiểm thử tự động `flutter test` bảo đảm không có lỗi hồi quy (regression).
