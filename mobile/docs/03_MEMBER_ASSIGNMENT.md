# Phân Công Nhiệm Vụ 5 Thành Viên (Team Assignment & Workload Matrix)
## Dự án: sports-store-mobile (Multi-brand Sports Store)

Phân công theo mô hình **Feature / Domain Owner**: Mỗi thành viên chịu trách nhiệm trọn vòng đời (End-to-End) cho các Use Cases được giao (UI Screen, BLoC/Cubit State Management, Repository/DataSource, kiểm thử Unit/Widget Test), đồng thời phối hợp Code Review chéo qua GitHub Pull Request.

---

### 📊 Bảng Ma Trận Khối Lượng Công Việc (Workload Matrix)

| Thành viên | Mã SV | Domain phụ trách chính | Danh sách Use Cases | Tổng số UC | Tổng Points | Tiến độ cá nhân |
| :--- | :---: | :--- | :--- | :---: | :---: | :---: |
| **Thái San Yo** | **CE190435** | **Home Layout, Catalog, Checkout & Shopping Cart** | **UC-04, UC-07, UC-08, UC-11, UC-12, UC-13** | **6 UCs** | **8 pts** | ⏳ 4 Done, 2 In Progress |
| **Nguyễn Hoài Ân** | **CE190990** | **Authentication, Order History, Details & Rating** | **UC-01, UC-14, UC-15, UC-23, UC-24** | **5 UCs** | **8 pts** | ⏳ 2 Done, 3 Not Yet |
| **Trần Hoàng Nhật** | **CE190581** | **Registration & Shipping Address (3 Cấp VN)** | **UC-02, UC-10, UC-18, UC-19** | **4 UCs** | **7 pts** | ✅ 4 Done (100%) |
| **Nguyễn Minh Nhật**| **CE191491** | **Logout, Variants, Categories & Voucher** | **UC-03, UC-06, UC-16, UC-21, UC-22** | **5 UCs** | **8 pts** | ⏳ 3 Done, 1 In Progress, 1 Not Yet |
| **Ngô Nhất Quý** | **CE190984** | **Product Detail, Search, Filter & Cancel Order** | **UC-05, UC-09, UC-17, UC-20** | **4 UCs** | **8 pts** | ⏳ 3 Done, 1 In Progress |
| **TỔNG CỘNG** | — | **5 Domain Owners** | **UC-01 → UC-24** | **24 UCs** | **39 pts** | **Tiến độ: 16/24 Done (24/39 pts)** |

---

### 📌 Phân Công Chi Tiết Theo Từng Thành Viên

#### 1. Thái San Yo (CE190435) — 6 UCs · 8 pts
- **UC-04 · View product list** (`P0` · Simple · 1 pt · Sprint 1): Grid 2 cột, Shimmer Skeleton, BLoC Infinite Scroll. (✅ **Done**)
- **UC-07 · Home layout** (`P1` · Simple · 1 pt · Sprint 1): `MainLayoutScreen` (BottomNavigationBar 3 tab), `HomeScreen` (Banner Carousel, Brand Chips, Featured Products) kết hợp cơ chế Lazy Login. (✅ **Done**)
- **UC-08 · Order items** (`P0` · Complex · 3 pts · Sprint 2): Màn hình xác nhận thanh toán (Checkout), chọn phương thức COD, gọi API tạo đơn hàng mới, nhánh `feat/order-items`. (⏳ **In progress** — Ân làm screen success rồi commit)
- **UC-11 · Add product to cart** (`P0` · Simple · 1 pt · Sprint 2): Logic thêm sản phẩm cùng size/màu vào `CartBloc`, lưu trạng thái cục bộ và phản hồi SnackBar/Badge. (✅ **Done**)
- **UC-12 · View shopping cart** (`P0` · Simple · 1 pt · Sprint 2): `CartScreen`, danh sách item có ảnh, size, số lượng, tự động tính tổng tiền VNĐ, nhánh `feat/view-shopping-cart`. (✅ **Done**)
- **UC-13 · Remove item from cart** (`P0` · Simple · 1 pt · Sprint 2): Thao tác vuốt xóa (Dismissible) hoặc nút thùng rác, dialog xác nhận xóa sản phẩm khỏi giỏ. (⏳ **In progress**)

#### 2. Nguyễn Hoài Ân (CE190990) — 5 UCs · 8 pts
- **UC-01 · Login** (`P0` · Medium · 2 pts · Sprint 1): Màn hình `LoginScreen`, gọi API đăng nhập, lưu JWT vào `SharedPreferences`, nhánh `feat/login`. (✅ **Done**)
- **UC-14 · View order history** (`P0` · Simple · 1 pt · Sprint 2): Màn hình lịch sử đơn hàng, hiển thị danh sách đơn kèm các tab trạng thái (Chờ xác nhận, Đang giao, Đã giao, Đã hủy). (✅ **Done**)
- **UC-15 · View order details** (`P0` · Medium · 2 pts · Sprint 3): Xem chi tiết từng đơn hàng: mã đơn, ngày đặt, địa chỉ nhận hàng, phương thức thanh toán, danh sách món và tổng thanh toán. (⏹ Not yet)
- **UC-23 · View product rating** (`P1` · Simple · 1 pt · Sprint 3): Hiển thị điểm số trung bình, biểu đồ sao và danh sách đánh giá của sản phẩm tại `ProductDetailScreen`. (⏹ Not yet)
- **UC-24 · Add product rating** (`P2` · Medium · 2 pts · Sprint 3): Form gửi bài đánh giá sản phẩm (chọn số sao, nhận xét text, ảnh chụp) sau khi đơn hoàn thành. (⏹ Not yet)

#### 3. Trần Hoàng Nhật (CE190581) — 4 UCs · 7 pts
- **UC-02 · Register** (`P0` · Medium · 2 pts · Sprint 1): Màn hình `RegisterScreen`, validate SĐT Việt Nam (+84), mật khẩu, gọi API đăng ký, nhánh `feat/register`. (✅ **Done**)
- **UC-10 · Add shipping address** (`P1` · Medium · 2 pts · Sprint 2): Form thêm địa chỉ mới với danh mục hành chính 3 cấp Việt Nam (Tỉnh/Thành phố → Quận/Huyện → Phường/Xã), nhánh `feat/add-shipping-address`. (✅ **Done**)
- **UC-18 · Edit shipping address** (`P1` · Medium · 2 pts · Sprint 3): Cập nhật thông tin địa chỉ đã lưu, đánh dấu địa chỉ mặc định, nhánh `feat/edit-shipping-address`. (✅ **Done**)
- **UC-19 · Delete shipping address** (`P1` · Simple · 1 pt · Sprint 3): Xóa địa chỉ khỏi sổ địa chỉ người dùng kèm dialog xác nhận, nhánh `feat/delete-shipping-address`. (✅ **Done**)

#### 4. Nguyễn Minh Nhật (CE191491) — 5 UCs · 8 pts
- **UC-03 · Logout** (`P0` · Simple · 1 pt · Sprint 1): Xóa token, reset navigation stack và state, nhánh `feat/logout`. (✅ **Done**)
- **UC-06 · Select product variant** (`P0` · Complex · 3 pts · Sprint 1): Bộ chọn Size (38-43) & Màu sắc động, kiểm tra tồn kho theo từng variant, cập nhật trạng thái mua. (✅ **Done**)
- **UC-16 · View product categories** (`P0` · Simple · 1 pt · Sprint 3): Lưới danh mục các dòng sản phẩm thể thao (Running, Football, Basketball, Gym...), nhánh `feat/view-product-categories`. (⏳ **In progress**)
- **UC-21 · View voucher list** (`P1` · Simple · 1 pt · Sprint 3): Kho voucher cá nhân trong Profile, sao chép mã code, nhánh `feat/view-voucher-list`. (✅ **Done**)
- **UC-22 · Apply voucher** (`P1` · Medium · 2 pts · Sprint 3): Áp dụng mã giảm giá tại màn hình Checkout và tính lại giá trị đơn hàng. (⏹ Not yet)

#### 5. Ngô Nhất Quý (CE190984) — 4 UCs · 8 pts
- **UC-05 · View product details** (`P0` · Medium · 2 pts · Sprint 1): `ProductDetailScreen` với Gallery ảnh đa góc nhìn, thông số kỹ thuật, mô tả và nút CTA "Thêm vào giỏ hàng". (✅ **Done**)
- **UC-09 · Search products by keyword** (`P1` · Simple · 1 pt · Sprint 2): `SearchScreen` với thanh tìm kiếm có debounce 400ms, lưu lịch sử tìm kiếm, nhánh `feat/search-products-by-keyword`. (✅ **Done**)
- **UC-17 · Filter products** (`P1` · Medium · 2 pts · Sprint 3): Bộ lọc nâng cao: khoảng giá (Price Range Slider), thương hiệu, danh mục con, nhánh `feat/filter-products`. (✅ **Done**)
- **UC-20 · Cancel order** (`P1` · Complex · 3 pts · Sprint 3): Nghiệp vụ hủy đơn hàng khi đơn ở trạng thái "Chờ xác nhận" (Pending), cập nhật lý do hủy. (⏳ **In progress**)

---

### 🌿 Quy Trình Git & Chuẩn Phối Hợp Làm Việc
1. **Quy tắc phân nhánh (Branching Convention)**:
   - Nhánh chính: `main` (Production / Integration).
   - Nhánh tính năng: `feat/[tên-tính-năng]` (VD: `feat/order-items`, `feat/view-voucher-list`).
2. **Quy tắc Code Review & Merge**:
   - Bắt buộc tạo Pull Request (PR) vào `main`.
   - Có ít nhất 1 thành viên review và approve trước khi merge.
   - Chạy kiểm thử tự động `flutter test` bảo đảm không có lỗi hồi quy (regression).
