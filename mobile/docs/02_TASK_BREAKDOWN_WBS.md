# Bảng Phân Rã Công Việc Kỹ Thuật (Work Breakdown Structure - WBS)
## Dự án: sports-store-mobile (Multi-brand Sports Store)

Tài liệu này chi tiết hóa toàn bộ các nhiệm vụ kỹ thuật cho **23 Use Cases** (tổng 38 Story Points) trải dài qua 3 Sprint. Kiến trúc tuân thủ nghiêm ngặt **Feature-First Clean Architecture**, BLoC/Cubit State Management, Dio Interceptors, Local Storage (`SharedPreferences`) và cơ chế xác thực **Lazy Login**.

---

## 🏃 SPRINT 1: Nền tảng Xác thực, Danh mục Sản phẩm & Home Layout (12 pts)
**Thời gian**: 11/10/2026 – 13/10/2026 · **Tiến độ**: 6/7 Done (11/12 pts)

---

### UC-01 · Login · `P0` · Medium · 2 pts · ✅ Hoàn thành
**Assignee**: Nguyễn Hoài Ân (CE190990) · **Thời gian**: 11/10/2026 – 13/10/2026 · **Branch**: [feat/login](https://github.com/SoYan2112/sports-store-final/tree/feat/login)

- [x] **[Presentation]** Dựng `LoginScreen` với các trường Email, Mật khẩu, nút CTA Đăng nhập phong cách Adidas.
- [x] **[State Management]** Viết `LoginViewModel` (ChangeNotifier / BLoC) quản lý trạng thái loading, lỗi validation inline.
- [x] **[Data Layer]** Triển khai `AuthRepository.login()` gọi REST API qua `Dio`, parse response trả về `User` entity.
- [x] **[Local Cache]** Lưu `accessToken` và thông tin người dùng vào `SharedPreferences`.
- [x] **[Testing]** Viết Unit Test kiểm thử luồng đăng nhập thành công và đăng nhập sai thông tin.

---

### UC-02 · Register · `P0` · Medium · 2 pts · ✅ Hoàn thành
**Assignee**: Trần Hoàng Nhật (CE190581) · **Thời gian**: 11/10/2026 – 13/10/2026 · **Branch**: [feat/register](https://github.com/SoYan2112/sports-store-final/tree/feat/register)

- [x] **[Presentation]** Dựng `RegisterScreen` gồm: Họ và tên, Email, Số điện thoại chuẩn VN (+84, 09x, 03x, 07x, 08x), Mật khẩu ≥ 6 ký tự.
- [x] **[State Management]** Xây dựng `RegisterCubit` phát các state: `RegisterInitial`, `RegisterLoading`, `RegisterSuccess`, `RegisterFailure`.
- [x] **[Domain & Data]** Định nghĩa `RegisterUseCase`, `AuthRepository.register()`, `AuthService.register()`.
- [x] **[Validation]** Bắt lỗi regex trực tiếp dưới từng TextField không làm gián đoạn trải nghiệm người dùng.
- [x] **[Testing]** Viết `register_cubit_test.dart` và `register_screen_test.dart` đạt pass 100%.

---

### UC-03 · Logout · `P0` · Simple · 1 pt · ✅ Hoàn thành
**Assignee**: Nguyễn Minh Nhật (CE191491) · **Thời gian**: 11/10/2026 – 12/10/2026 · **Branch**: [feat/logout](https://github.com/SoYan2112/sports-store-final/tree/feat/logout)

- [x] **[Presentation]** Thêm nút Đăng xuất kèm AlertDialog xác nhận trên AppBar/Header (`ProductListScreen`, `ProfileScreen`).
- [x] **[Data Layer]** Viết hàm `logout()` trong `AuthRepository` xóa sạch `accessToken` và cache người dùng trong `SharedPreferences`.
- [x] **[Navigation]** Xóa sạch Navigation Stack (`pushAndRemoveUntil`) đưa người dùng về trạng thái Guest / Login an toàn.

---

### UC-04 · View product list · `P0` · Simple · 1 pt · ✅ Hoàn thành
**Assignee**: Thái San Yo (CE190435) · **Thời gian**: 11/10/2026 – 13/10/2026

- [x] **[Presentation]** Dựng `ProductListScreen` bố cục `CustomScrollView` + `SliverGrid` 2 cột đối xứng (tỷ lệ thẻ 0.65).
- [x] **[UI Widget]** Tạo `ProductCard` (ảnh tỷ lệ 3:4, Hero animation, badge Hot/New/Sale, format tiền tệ VNĐ `1.950.000 ₫`).
- [x] **[State Management]** Xây dựng `ProductBloc` lắng nghe `FetchProductsEvent` & `FetchMoreProductsEvent` emit các state: `ProductInitial`, `ProductLoading`, `ProductLoaded`, `ProductError`.
- [x] **[Infinite Scroll]** Lắng nghe `ScrollController` với threshold cách đáy 200px, cơ chế guard clause chống spam request.
- [x] **[Skeletal Loading]** Xây dựng `ProductCardSkeleton` với hiệu ứng Shimmer Animation (nhịp thở 1000ms).
- [x] **[Testing]** Hoàn thành `product_bloc_test.dart` kiểm thử luồng phân trang thành công và xử lý ngoại lệ mạng.

---

### UC-05 · View product details · `P0` · Medium · 2 pts · ✅ Hoàn thành
**Assignee**: Ngô Nhất Quý (CE190984) · **Thời gian**: 11/10/2026 – 13/10/2026

- [x] **[Presentation]** Dựng `ProductDetailScreen` với Hero Image, Carousel gallery đa góc nhìn sản phẩm, thông số thể thao.
- [x] **[State Management]** Xây dựng `ProductDetailCubit` gọi `GetProductDetailUseCase` emit `ProductDetailLoading`, `ProductDetailLoaded`.
- [x] **[Domain & Data]** Định nghĩa `ProductEntity`, `ProductModel.fromJson()`, fallback mock chi tiết sản phẩm chất lượng cao.
- [x] **[Bottom Action Bar]** Nút "Thêm vào giỏ hàng" gắn cố định ở chân màn hình kèm hiển thị giá tiền nổi bật.

---

### UC-06 · Select product variant · `P0` · Complex · 3 pts · ✅ Hoàn thành
**Assignee**: Nguyễn Minh Nhật (CE191491) · **Thời gian**: 11/10/2026 – 13/10/2026

- [x] **[Presentation]** Dựng bộ chọn Size giày (38, 39, 40, 41, 42, 43) dạng Pill Button tròn chuẩn ngón tay bấm.
- [x] **[Presentation]** Dựng bộ chọn màu sắc (Color Palette Circles) với viền highlight và icon check khi được chọn.
- [x] **[Business Logic]** Kiểm tra số lượng tồn kho (`stock`) theo từng cặp size/color; disable nút mua nếu biến thể hết hàng.
- [x] **[Interactive Feedback]** Cập nhật hình ảnh tương ứng với phiên bản màu đang chọn và rung nhẹ phản hồi xúc giác.

---

### UC-07 · Home layout · `P1` · Simple · 1 pt · ⏳ Đang thực hiện
**Assignee**: Thái San Yo (CE190435) · **Thời gian**: 14/10/2026 – 21/10/2026

- [ ] **[Architecture / Shell]** Dựng `MainLayoutScreen` chứa `BottomNavigationBar` 4 tab:
  - Tab 0: `HomeScreen` (Trang chủ & Khám phá).
  - Tab 1: `ProductListScreen` (Duyệt toàn bộ danh mục sản phẩm).
  - Tab 2: `CartScreen` (Giỏ hàng).
  - Tab 3: `ProfileScreen` (Hồ sơ & Xác thực).
- [ ] **[Lazy Login Flow]** Khởi tạo ứng dụng kiểm tra `accessToken` trong `SharedPreferences`:
  - Chưa đăng nhập: Emit `AuthUnauthenticated` → Vào thẳng `MainLayoutScreen` (Khách vãng lai xem hàng tự do).
  - Đã có token: Emit `AuthAuthenticated` với dữ liệu User đã lưu.
- [ ] **[Tab Profile Logic]** Bọc tab Profile bằng `BlocBuilder<AuthCubit, AuthState>`:
  - Trạng thái `AuthUnauthenticated`: Hiển thị giao diện Guest (Avatar mặc định, nút CTA "Đăng nhập / Đăng ký"). Bấm Đăng nhập mở đè `LoginScreen`.
  - Trạng thái `AuthAuthenticated`: Hiển thị thông tin người dùng (Tên, Email, SĐT, nút Đăng xuất).
- [ ] **[Home UI Components]** Dựng giao diện `HomeScreen`:
  - `HomeHeader`: Chào người dùng / Khách, icon chuông thông báo.
  - `HomeBannerCarousel`: Banner trượt tự động các chiến dịch marketing thể thao bằng `PageView.builder` + `Timer.periodic`.
  - `QuickCategoryChips`: Dãy danh mục nhanh nằm ngang (Giày chạy bộ, Bóng rổ, Quần áo, Phụ kiện).
  - `FeaturedProductsSection`: Danh mục sản phẩm nổi bật có nút "Xem tất cả" chuyển sang Tab 1 (`ProductListScreen`).

---

## 🛒 SPRINT 2: Giỏ hàng, Đặt hàng, Tìm kiếm & Địa chỉ giao hàng (11 pts)
**Thời gian**: 14/10/2026 – 21/10/2026 · **Tiến độ**: 2/7 In progress (4/11 pts)

---

### UC-08 · Order selected items in cart · `P0` · Complex · 3 pts · ⏹ Chưa bắt đầu
**Assignee**: Nguyễn Hoài Ân (CE190990) · **Thời gian**: 14/10/2026 – 21/10/2026

- [ ] **[Presentation]** Dựng `CheckoutScreen` hiển thị tóm tắt đơn hàng: Danh sách món chọn mua, địa chỉ nhận hàng, phương thức vận chuyển.
- [ ] **[Payment Method]** Tích hợp lựa chọn phương thức thanh toán: **COD (Thanh toán khi nhận hàng)** mặc định, hỗ trợ mở rộng VNPAY/MoMo.
- [ ] **[State Management]** Xây dựng `CheckoutBloc` xử lý event `PlaceOrderEvent` emit `CheckoutLoading`, `CheckoutSuccess(orderId)`, `CheckoutFailure`.
- [ ] **[Domain & Data]** `CreateOrderUseCase`, `OrderRepository.createOrder()` gọi `POST /api/orders` gửi payload chi tiết.
- [ ] **[Post-Checkout]** Xóa các item đã đặt khỏi `CartBloc`, điều hướng sang màn hình Đặt hàng thành công (`OrderSuccessScreen`).

---

### UC-09 · Search products by keyword · `P1` · Simple · 1 pt · ⏹ Chưa bắt đầu
**Assignee**: Ngô Nhất Quý (CE190984) · **Thời gian**: 14/10/2026 – 21/10/2026

- [ ] **[Presentation]** Dựng `SearchScreen` với thanh tìm kiếm tự động focus bàn phím, nút Clear nhanh nội dung.
- [ ] **[Debounce Logic]** Triển khai cơ chế Debounce 400-500ms khi gõ phím để tránh gửi request dồn dập lên server.
- [ ] **[State Management]** Xây dựng `SearchBloc` lắng nghe `SearchQueryChanged` emit `SearchLoading`, `SearchLoaded`, `SearchEmpty`.
- [ ] **[Search History]** Lưu lịch sử tìm kiếm gần nhất (tối đa 10 từ khóa) vào `SharedPreferences`, cho phép xóa từng từ khóa hoặc xóa tất cả.

---

### UC-10 · Add shipping address · `P1` · Medium · 2 pts · ⏳ Đang thực hiện
**Assignee**: Trần Hoàng Nhật (CE190581) · **Thời gian**: 14/10/2026 – 21/10/2026

- [ ] **[Presentation]** Dựng `AddAddressScreen` gồm: Tên người nhận, Số điện thoại người nhận, Địa chỉ cụ thể (Số nhà, tên đường).
- [ ] **[Vietnam 3-Tier Address]** Dropdown cascading chọn địa chỉ 3 cấp chuẩn hành chính Việt Nam: Tỉnh/Thành phố → Quận/Huyện → Phường/Xã.
- [ ] **[State Management]** `AddressCubit` xử lý nạp danh mục địa phương và phát state lưu địa chỉ mới.
- [ ] **[Data Layer]** `AddressRepository.addAddress()` lưu địa chỉ vào hệ thống và đồng bộ cache người dùng.

---

### UC-11 · Add product to cart · `P0` · Medium · 2 pts · ⏳ Đang thực hiện
**Assignee**: Thái San Yo (CE190435) · **Thời gian**: 14/10/2026 – 21/10/2026

- [ ] **[Domain & Entity]** Thiết kế `CartItemEntity` gồm: `productId`, `name`, `price`, `imageUrl`, `selectedSize`, `selectedColor`, `quantity`.
- [ ] **[State Management]** Xây dựng `CartBloc` xử lý `AddToCartEvent`:
  - Nếu sản phẩm cùng size/màu đã có trong giỏ: Tăng `quantity += 1`.
  - Nếu là sản phẩm/biến thể mới: Nối vào danh sách giỏ hàng.
- [ ] **[Local Persistence]** Lưu cache giỏ hàng tạm thời vào `SharedPreferences` để không bị mất khi đóng app.
- [ ] **[UI Feedback]** Hiển thị SnackBar xác nhận đẹp mắt với nút "Đi đến giỏ hàng", cập nhật Badge số lượng trên icon Cart.

---

### UC-12 · View shopping cart · `P0` · Simple · 1 pt · ⏹ Chưa bắt đầu
**Assignee**: Thái San Yo (CE190435) · **Thời gian**: 14/10/2026 – 21/10/2026

- [ ] **[Presentation]** Dựng `CartScreen` hiển thị danh sách các món đồ đã chọn trong giỏ hàng.
- [ ] **[Quantity Selector]** Bộ nút tăng/giảm số lượng (+ / -) cho từng item, tự động cập nhật lại tổng tiền.
- [ ] **[Price Calculation]** Tự động tính: Tạm tính (Subtotal), Phí vận chuyển ước tính, Tổng thanh toán hiển thị chuẩn format VNĐ.
- [ ] **[Empty State]** Màn hình giỏ hàng trống thân thiện với minh họa thể thao và nút CTA "Tiếp tục mua sắm".

---

### UC-13 · Remove item from cart · `P0` · Simple · 1 pt · ⏹ Chưa bắt đầu
**Assignee**: Thái San Yo (CE190435) · **Thời gian**: 14/10/2026 – 21/10/2026

- [ ] **[Interaction]** Hỗ trợ thao tác vuốt ngang để xóa (`Dismissible` widget) có nền đỏ và icon thùng rác.
- [ ] **[Confirmation]** Hộp thoại xác nhận: "Bạn có chắc chắn muốn bỏ sản phẩm này khỏi giỏ hàng?".
- [ ] **[State Update]** Bắn `RemoveFromCartEvent` vào `CartBloc`, cập nhật lại danh sách và tổng tiền tức thì.

---

### UC-14 · View order history · `P0` · Simple · 1 pt · ⏹ Chưa bắt đầu
**Assignee**: Nguyễn Hoài Ân (CE190990) · **Thời gian**: 14/10/2026 – 21/10/2026

- [ ] **[Presentation]** Dựng `OrderHistoryScreen` với các Tab trạng thái đơn hàng: Tất cả, Chờ xác nhận, Đang giao, Đã hoàn thành, Đã hủy.
- [ ] **[UI Card]** `OrderCard` hiển thị: Mã đơn hàng, ngày đặt, ảnh thu nhỏ sản phẩm đầu tiên, tổng số tiền và badge trạng thái màu sắc riêng.
- [ ] **[State Management]** `OrderBloc` xử lý `FetchOrderHistoryEvent` emit `OrderHistoryLoading`, `OrderHistoryLoaded`.

---

## 📦 SPRINT 3: Quản lý Đơn hàng, Bộ lọc & Quản trị Danh mục (15 pts)
**Thời gian**: 22/10/2026 – 29/10/2026 · **Tiến độ**: 0/9 Not yet (0/15 pts)

---

### UC-15 · View order details · `P0` · Medium · 2 pts · ⏹ Chưa bắt đầu
**Assignee**: Nguyễn Hoài Ân (CE190990) · **Thời gian**: 22/10/2026 – 29/10/2026

- [ ] **[Presentation]** Dựng `OrderDetailScreen` hiển thị toàn bộ hành trình đơn: Timeline vận chuyển, thông tin người nhận, danh sách từng sản phẩm.
- [ ] **[Data Layer]** `OrderRepository.getOrderById(orderId)` gọi `GET /api/orders/{id}`.

---

### UC-16 · View product categories · `P0` · Simple · 1 pt · ⏹ Chưa bắt đầu
**Assignee**: Nguyễn Minh Nhật (CE191491) · **Thời gian**: 22/10/2026 – 29/10/2026

- [ ] **[Presentation]** Dựng `CategoryListScreen` dạng lưới danh mục với ảnh đại diện sắc nét cho từng ngành hàng thể thao.
- [ ] **[Navigation]** Bấm vào danh mục → Mở `ProductListScreen` kèm tham số lọc `categoryId`.

---

### UC-17 · Filter products · `P1` · Medium · 2 pts · ⏹ Chưa bắt đầu
**Assignee**: Ngô Nhất Quý (CE190984) · **Thời gian**: 22/10/2026 – 29/10/2026

- [ ] **[UI BottomSheet]** Dựng `FilterBottomSheet` gồm: Khoảng giá (RangeSlider VNĐ), Thương hiệu (Nike, Adidas, Puma, Reebok), Đánh giá sao (≥ 4 sao).
- [ ] **[State Management]** Truyền bộ lọc vào `ProductBloc` qua `FetchProductsEvent(filterParams)` để tải lại danh sách tương ứng.

---

### UC-18 · Edit shipping address · `P1` · Medium · 2 pts · ⏹ Chưa bắt đầu
**Assignee**: Trần Hoàng Nhật (CE190581) · **Thời gian**: 22/10/2026 – 29/10/2026

- [ ] **[Presentation]** Màn hình chỉnh sửa địa chỉ, tự động điền sẵn các thông tin cũ của địa chỉ cần sửa.
- [ ] **[Logic]** Cho phép đặt làm địa chỉ giao hàng mặc định (Default Address).

---

### UC-19 · Delete shipping address · `P1` · Simple · 1 pt · ⏹ Chưa bắt đầu
**Assignee**: Trần Hoàng Nhật (CE190581) · **Thời gian**: 22/10/2026 – 29/10/2026

- [ ] **[Interaction]** Nút xóa địa chỉ với hộp thoại xác nhận, không cho phép xóa nếu là địa chỉ duy nhất đang dùng cho đơn hàng chờ giao.

---

### UC-20 · Cancel order · `P1` · Complex · 3 pts · ⏹ Chưa bắt đầu
**Assignee**: Ngô Nhất Quý (CE190984) · **Thời gian**: 22/10/2026 – 29/10/2026

- [ ] **[Business Logic]** Kiểm tra điều kiện hủy: Chỉ cho phép hủy khi đơn ở trạng thái `Pending` (Chờ xác nhận).
- [ ] **[UI Form]** Hộp thoại chọn lý do hủy đơn (Đổi ý, Sai địa chỉ, Muốn đổi size/màu...).
- [ ] **[API Integration]** Gọi `POST /api/orders/{id}/cancel`, cập nhật lại trạng thái đơn hàng trên giao diện tức thì.

---

### UC-21 · Add product categories · `P1` · Simple · 1 pt · ⏹ Chưa bắt đầu
**Assignee**: Nguyễn Minh Nhật (CE191491) · **Thời gian**: 22/10/2026 – 29/10/2026

- [ ] **[Admin Feature]** Màn hình thêm danh mục sản phẩm mới: Tên danh mục, Mô tả ngắn, Tải ảnh URL hoặc chọn ảnh đại diện.
- [ ] **[Validation]** Kiểm tra không cho trùng tên danh mục đã có trong hệ thống.

---

### UC-22 · Edit product categories · `P1` · Medium · 2 pts · ⏹ Chưa bắt đầu
**Assignee**: Nguyễn Minh Nhật (CE191491) · **Thời gian**: 22/10/2026 – 29/10/2026

- [ ] **[Admin Feature]** Chỉnh sửa tên, ảnh đại diện và thứ tự hiển thị của danh mục.

---

### UC-23 · Remove product categories · `P1` · Simple · 1 pt · ⏹ Chưa bắt đầu
**Assignee**: Thái San Yo (CE190435) · **Thời gian**: 22/10/2026 – 29/10/2026

- [ ] **[Admin Feature]** Xóa danh mục sản phẩm khỏi hệ thống.
- [ ] **[Integrity Check]** Kiểm tra ràng buộc dữ liệu: Nếu còn sản phẩm thuộc danh mục này, cảnh báo yêu cầu di chuyển sản phẩm trước khi xóa.
