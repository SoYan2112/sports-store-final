# Bảng Phân Rã Công Việc Kỹ Thuật (Work Breakdown Structure - WBS)
## Dự án: sports-store-mobile (Multi-brand Sports Store)

Tài liệu này chi tiết hóa toàn bộ các nhiệm vụ kỹ thuật cho **24 Use Cases** (tổng 39 Story Points) trải dài qua 3 Sprint. Kiến trúc tuân thủ nghiêm ngặt **Feature-First Clean Architecture**, BLoC/Cubit State Management, Dio Interceptors, Local Storage (`SharedPreferences`) và cơ chế xác thực **Lazy Login**.

---

## 🏃 SPRINT 1: Nền tảng Xác thực, Danh mục Sản phẩm & Home Layout (12 pts)
**Thời gian**: 11/10/2026 – 13/10/2026 · **Tiến độ**: 7/7 Done (12/12 pts)

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
- [x] **[Interactive Feedback]** Cập nhật hình ảnh tương ứng với phiên bản màu đang chọn và phản hồi giao diện tức thì.

---

### UC-07 · Home layout · `P1` · Simple · 1 pt · ✅ Hoàn thành
**Assignee**: Thái San Yo (CE190435) · **Thời gian**: 14/10/2026 – 15/10/2026 · **Branch**: [feat/home-layout](https://github.com/SoYan2112/sports-store-final/commit/8ae3a4c5677629c151cebb39f520ff7f77bc1e33)

- [x] **[Architecture / Shell]** Dựng `MainLayoutScreen` chứa `BottomNavigationBar` 3 tab:
  - Tab 0: `HomeScreen` (Trang chủ & Khám phá).
  - Tab 1: `CartScreen` (Giỏ hàng).
  - Tab 2: `ProfileScreen` (Hồ sơ & Xác thực).
- [x] **[Lazy Login Flow]** Khởi tạo ứng dụng kiểm tra `accessToken` trong `SharedPreferences`:
  - Chưa đăng nhập: Emit `AuthUnauthenticated` → Vào thẳng `MainLayoutScreen` (Khách vãng lai xem hàng tự do).
  - Đã có token: Emit `AuthAuthenticated` với dữ liệu User đã lưu.
- [x] **[Tab Profile Logic]** Bọc tab Profile bằng `BlocBuilder<AuthCubit, AuthState>`:
  - Trạng thái `AuthUnauthenticated`: Hiển thị giao diện Guest (Avatar mặc định, nút CTA "Đăng nhập / Đăng ký"). Bấm Đăng nhập mở đè `LoginScreen`.
  - Trạng thái `AuthAuthenticated`: Hiển thị thông tin người dùng (Tên, Email, nút Đăng xuất).
- [x] **[Home UI Components]** Dựng giao diện `HomeScreen`:
  - `HomeHeader`: Chào người dùng / Khách, icon chuông thông báo.
  - `HomeBannerCarousel`: Banner trượt tự động các chiến dịch marketing thể thao bằng `PageView.builder` + `Timer.periodic`.
  - `QuickCategoryChips`: Dãy danh mục nhanh nằm ngang (Nike, Adidas, Puma, Reebok, Under Armour).
  - `FeaturedProductsSection`: Grid 2 cột ngắn (4 sản phẩm hot) kèm nút "Xem tất cả" mở `ProductListScreen`.
- [x] **[Testing]** Viết `auth_cubit_test.dart` kiểm thử đầy đủ các trạng thái Lazy Login đạt pass 100%.

---

## 🛒 SPRINT 2: Giỏ hàng, Đặt hàng, Tìm kiếm & Địa chỉ giao hàng (10 pts)
**Thời gian**: 14/10/2026 – 21/10/2026 · **Tiến độ**: 6/7 Done, 1 In progress (7/10 pts)

---

### UC-08 · Order items · `P0` · Complex · 3 pts · ⏳ Đang thực hiện
**Assignee**: Thái San Yo (CE190435) · **Thời gian**: 14/10/2026 – 21/10/2026 · **Branch**: [feat/order-items](https://github.com/SoYan2112/sports-store-final/tree/feat/order-items)  
*Ghi chú: Ân làm screen success rồi [commit](https://github.com/SoYan2112/sports-store-final/commit/6021ed4fef43a27c5dbd2aa1ad8244574cffd2d2), commit lên branch [feat/order-items](https://github.com/SoYan2112/sports-store-final/tree/feat/order-items)*

- [ ] **[Presentation]** Dựng `CheckoutScreen` hiển thị tóm tắt đơn hàng: Danh sách món chọn mua, địa chỉ nhận hàng, phương thức vận chuyển.
- [ ] **[Payment Method]** Tích hợp lựa chọn phương thức thanh toán: **COD (Thanh toán khi nhận hàng)** mặc định, hỗ trợ mở rộng VNPAY/MoMo.
- [ ] **[State Management]** Xây dựng `CheckoutBloc` xử lý event `PlaceOrderEvent` emit `CheckoutLoading`, `CheckoutSuccess(orderId)`, `CheckoutFailure`.
- [ ] **[Domain & Data]** `CreateOrderUseCase`, `OrderRepository.createOrder()` gọi `POST /api/orders` gửi payload chi tiết.
- [x] **[Post-Checkout]** Dựng màn hình Đặt hàng thành công (`ordered-screen.dart` / `OrderSuccessScreen`).

---

### UC-09 · Search products by keyword · `P1` · Simple · 1 pt · ✅ Hoàn thành (17/10/2026)
**Assignee**: Ngô Nhất Quý (CE190984) · **Thời gian**: 14/10/2026 – 21/10/2026 · **Branch**: [feat/search-products-by-keyword](https://github.com/SoYan2112/sports-store-final/tree/feat/search-products-by-keyword)

- [x] **[Presentation]** Dựng `SearchScreen` với thanh tìm kiếm tự động focus bàn phím, nút Clear nhanh nội dung.
- [x] **[Debounce Logic]** Triển khai cơ chế Debounce 400-500ms khi gõ phím để tránh gửi request dồn dập lên server.
- [x] **[State Management]** Xây dựng `SearchCubit` lắng nghe `search()` emit `SearchLoading`, `SearchLoaded`, `SearchEmpty`.
- [x] **[Search History]** Lưu lịch sử tìm kiếm gần nhất vào `SharedPreferences`, cho phép xóa từng từ khóa hoặc xóa tất cả.
- [x] **[Testing]** Viết `search_cubit_test.dart` và `search_screen_test.dart` đạt pass 100%.

---

### UC-10 · Add shipping address · `P1` · Medium · 2 pts · ✅ Hoàn thành (25/10/2026)
**Assignee**: Trần Hoàng Nhật (CE190581) · **Thời gian**: 14/10/2026 – 21/10/2026 · **Branch**: [feat/add-shipping-address](https://github.com/SoYan2112/sports-store-final/tree/feat/add-shipping-address)

- [x] **[Presentation]** Dựng `AddAddressScreen` gồm: Tên người nhận, Số điện thoại người nhận, Địa chỉ cụ thể (Số nhà, tên đường).
- [x] **[Vietnam 3-Tier Address]** `VietnamAddressPickerBottomSheet` chọn địa chỉ 3 cấp chuẩn hành chính Việt Nam: Tỉnh/Thành phố → Quận/Huyện → Phường/Xã.
- [x] **[State Management]** `AddressCubit` xử lý nạp danh mục địa phương và phát state lưu địa chỉ mới.
- [x] **[Data Layer]** `AddressRepository.addAddress()` lưu địa chỉ vào hệ thống và đồng bộ cache người dùng qua `SharedPreferences`.
- [x] **[Testing]** Viết `add_address_screen_test.dart` và `address_cubit_test.dart` pass 100%.

---

### UC-11 · Add product to cart · `P0` · Simple · 1 pt · ✅ Hoàn thành (27/10/2026)
**Assignee**: Thái San Yo (CE190435) · **Thời gian**: 14/10/2026 – 21/10/2026 · **Branch**: [feat/add-product-to-cart](https://github.com/SoYan2112/sports-store-final/tree/feat/add-product-to-cart)

- [x] **[Domain & Entity]** Thiết kế `CartItemEntity` gồm: `productId`, `name`, `price`, `imageUrl`, `selectedSize`, `selectedColor`, `quantity`.
- [x] **[State Management]** Xây dựng `CartBloc` xử lý `AddToCartEvent`:
  - Nếu sản phẩm cùng size/màu đã có trong giỏ: Tăng `quantity += 1`.
  - Nếu là sản phẩm/biến thể mới: Nối vào danh sách giỏ hàng.
- [x] **[Local Persistence]** Lưu cache giỏ hàng tạm thời vào `SharedPreferences` để không bị mất khi đóng app.
- [x] **[UI Feedback]** Hiển thị SnackBar xác nhận đẹp mắt với nút "Đi đến giỏ hàng", cập nhật Badge số lượng trên icon Cart.
- [x] **[Testing]** Viết `cart_item_entity_test.dart` và `cart_bloc_test.dart` pass 100%.

---

### UC-12 · View shopping cart · `P0` · Simple · 1 pt · ✅ Hoàn thành (27/10/2026)
**Assignee**: Thái San Yo (CE190435) · **Thời gian**: 14/10/2026 – 21/10/2026 · **Branch**: [feat/view-shopping-cart](https://github.com/SoYan2112/sports-store-final/tree/feat/view-shopping-cart)

- [x] **[Presentation]** Dựng `CartScreen` hiển thị danh sách các món đồ đã chọn trong giỏ hàng.
- [x] **[Quantity Selector]** Bộ nút tăng/giảm số lượng (+ / -) cho từng item, tự động cập nhật lại tổng tiền.
- [x] **[Price Calculation]** Tự động tính: Tạm tính (Subtotal), Tổng thanh toán hiển thị chuẩn format VNĐ (`3.900.000 ₫`).
- [x] **[Empty State]** Màn hình giỏ hàng trống thân thiện với minh họa thể thao và nút CTA "Khám phá ngay".
- [x] **[Testing]** Viết `cart_screen_test.dart` đạt pass 100%.

---

### UC-13 · Remove item from cart · `P0` · Simple · 1 pt · ✅ Hoàn thành (27/10/2026)
**Assignee**: Thái San Yo (CE190435) · **Thời gian**: 14/10/2026 – 21/10/2026 · **Branch**: [feat/remove-item-from-cart](https://github.com/SoYan2112/sports-store-final/tree/feat/remove-item-from-cart)

- [x] **[Interaction]** Hỗ trợ thao tác vuốt ngang để xóa (`Dismissible` widget) có nền đỏ và icon thùng rác, kèm nút icon X tại từng thẻ sản phẩm.
- [x] **[Confirmation]** Hộp thoại xác nhận: "Bạn có chắc chắn muốn bỏ sản phẩm này khỏi giỏ hàng?".
- [x] **[State Update]** Bắn `RemoveFromCartEvent` và `ClearCartEvent` vào `CartBloc`, cập nhật lại danh sách và tổng tiền tức thì.
- [x] **[Testing]** Viết `cart_bloc_test.dart` và `cart_screen_test.dart` pass 100%.

---

### UC-14 · View order history · `P0` · Simple · 1 pt · ✅ Hoàn thành (26/10/2026)
**Assignee**: Nguyễn Hoài Ân (CE190990) · **Thời gian**: 14/10/2026 – 21/10/2026 · **Branch**: [feat/view-order-history](https://github.com/SoYan2112/sports-store-final/tree/feat/view-order-history)

- [x] **[Presentation]** Dựng `OrderHistoryScreen` với các Tab trạng thái đơn hàng: Tất cả, Chờ xác nhận, Đang giao, Đã hoàn thành, Đã hủy.
- [x] **[UI Card]** Hiển thị danh sách thẻ đơn hàng kèm ngày đặt, trạng thái đơn, giá tiền chuẩn định dạng VNĐ.
- [x] **[Integration]** Tích hợp đường dẫn mở từ `ProfileScreen`.

---

## 📦 SPRINT 3: Quản lý Đơn hàng nâng cao, Bộ lọc, Voucher & Đánh giá (17 pts)
**Thời gian**: 22/10/2026 – 29/10/2026 · **Tiến độ**: 4/10 Hoàn thành (6/17 pts)

---

### UC-15 · View order details · `P0` · Medium · 2 pts · ⏹ Chưa bắt đầu
**Assignee**: Nguyễn Hoài Ân (CE190990) · **Thời gian**: 22/10/2026 – 29/10/2026

- [ ] **[Presentation]** Dựng `OrderDetailScreen` hiển thị toàn bộ hành trình đơn: Timeline vận chuyển, thông tin người nhận, danh sách từng sản phẩm.
- [ ] **[Data Layer]** `OrderRepository.getOrderById(orderId)` gọi `GET /api/orders/{id}`.

---

### UC-16 · View product categories · `P0` · Simple · 1 pt · ⏳ Đang thực hiện
**Assignee**: Nguyễn Minh Nhật (CE191491) · **Thời gian**: 22/10/2026 – 29/10/2026 · **Branch**: [feat/view-product-categories](https://github.com/SoYan2112/sports-store-final/tree/feat/view-product-categories)

- [x] **[Presentation]** Dựng `CategoryListScreen` dạng lưới danh mục với ảnh đại diện sắc nét cho từng ngành hàng thể thao.
- [x] **[Navigation]** Bấm vào danh mục → Mở `ProductListScreen` kèm tham số lọc `categoryId`.
- [ ] **[Refinement]** Hoàn thiện liên kết bộ lọc đồng bộ giữa Category và Home layout.

---

### UC-17 · Filter products · `P1` · Medium · 2 pts · ✅ Hoàn thành (26/10/2026)
**Assignee**: Ngô Nhất Quý (CE190984) · **Thời gian**: 22/10/2026 – 29/10/2026 · **Branch**: [feat/filter-products](https://github.com/SoYan2112/sports-store-final/tree/feat/filter-products)

- [x] **[UI BottomSheet]** Dựng `FilterBottomSheet` gồm: Bộ chọn Khoảng giá min-max, Lọc theo Thương hiệu (Nike, Adidas, Puma, Jordan...), Danh mục con.
- [x] **[State Management]** Xây dựng `FilterCubit` quản lý `FilterState`, tích hợp liên thông với `HomeScreen` và `ProductListScreen`.
- [x] **[Testing]** Viết `filter_cubit_test.dart` và `filter_bottom_sheet_test.dart` pass 100%.

---

### UC-18 · Edit shipping address · `P1` · Medium · 2 pts · ✅ Hoàn thành (25/10/2026)
**Assignee**: Trần Hoàng Nhật (CE190581) · **Thời gian**: 22/10/2026 – 29/10/2026 · **Branch**: [feat/edit-shipping-address](https://github.com/SoYan2112/sports-store-final/tree/feat/edit-shipping-address)

- [x] **[Presentation]** Dựng `EditAddressScreen` tự động load và điền sẵn thông tin cũ của địa chỉ.
- [x] **[Logic]** Cho phép chỉnh sửa thông tin chi tiết và đặt làm địa chỉ mặc định (`isDefault`).
- [x] **[Testing]** Viết `edit_address_screen_test.dart` pass 100%.

---

### UC-19 · Delete shipping address · `P1` · Simple · 1 pt · ✅ Hoàn thành (25/10/2026)
**Assignee**: Trần Hoàng Nhật (CE190581) · **Thời gian**: 22/10/2026 – 29/10/2026 · **Branch**: [feat/delete-shipping-address](https://github.com/SoYan2112/sports-store-final/tree/feat/delete-shipping-address)

- [x] **[Presentation & Interaction]** Nút Xóa địa chỉ trên thẻ `AddressCard` trong `AddressListScreen` kèm AlertDialog xác nhận xóa.
- [x] **[Domain & Data]** Triển khai `DeleteAddressUseCase` và xử lý cập nhật state trong `AddressCubit`.

---

### UC-20 · Cancel order · `P1` · Complex · 3 pts · ⏳ Đang thực hiện
**Assignee**: Ngô Nhất Quý (CE190984) · **Thời gian**: 22/10/2026 – 29/10/2026

- [ ] **[Business Logic]** Kiểm tra điều kiện hủy: Chỉ cho phép hủy khi đơn ở trạng thái `Pending` (Chờ xác nhận).
- [ ] **[UI Form]** Hộp thoại chọn lý do hủy đơn (Đổi ý, Sai địa chỉ, Muốn đổi size/màu...).
- [ ] **[API Integration]** Gọi `POST /api/orders/{id}/cancel`, cập nhật lại trạng thái đơn hàng trên giao diện tức thì.

---

### UC-21 · View voucher list · `P1` · Simple · 1 pt · ✅ Hoàn thành (26/10/2026)
**Assignee**: Nguyễn Minh Nhật (CE191491) · **Thời gian**: 22/10/2026 – 29/10/2026 · **Branch**: [feat/view-voucher-list](https://github.com/SoYan2112/sports-store-final/tree/feat/view-voucher-list)

- [x] **[Presentation]** Dựng `VoucherListScreen` hiển thị kho voucher trong trang cá nhân `ProfileScreen`.
- [x] **[UI Component]** Thiết kế thẻ `VoucherCard` hiển thị: Mã code, Mức giảm (VNĐ / %), Điều kiện áp dụng, Hạn sử dụng, Nút copy mã.
- [x] **[State Management & Data]** `VoucherCubit`, `GetVouchersUseCase`, `VoucherRepositoryImpl` và mock/remote data source.
- [x] **[Testing]** Viết `voucher_card_test.dart`, `voucher_cubit_test.dart`, `voucher_list_screen_test.dart` pass 100%.

---

### UC-22 · Apply voucher · `P1` · Medium · 2 pts · ⏹ Chưa bắt đầu
**Assignee**: Nguyễn Minh Nhật (CE191491) · **Thời gian**: 22/10/2026 – 29/10/2026

- [ ] **[Presentation]** Ô nhập mã giảm giá và nút "Chọn voucher từ kho" trong màn hình Checkout (`CheckoutScreen`).
- [ ] **[Business Logic]** Kiểm tra tính hợp lệ: Giá trị đơn hàng tối thiểu, ngày hết hạn, danh mục áp dụng.
- [ ] **[State Update]** Cập nhật số tiền giảm giá và tính toán lại tổng tiền thanh toán hiển thị theo format VNĐ.

---

### UC-23 · View product rating · `P1` · Simple · 1 pt · ⏹ Chưa bắt đầu
**Assignee**: Nguyễn Hoài Ân (CE190990) · **Thời gian**: 22/10/2026 – 29/10/2026

- [ ] **[Presentation]** Phần đánh giá tại `ProductDetailScreen`: Thống kê số sao trung bình (1-5 sao), thanh phân bổ điểm đánh giá.
- [ ] **[Review List]** Danh sách các bài nhận xét của khách hàng kèm tên, ngày đánh giá, số sao và bình luận chi tiết.
- [ ] **[Data & Domain]** `GetProductReviewsUseCase`, gọi API nạp danh sách đánh giá theo `productId`.

---

### UC-24 · Add product rating · `P2` · Medium · 2 pts · ⏹ Chưa bắt đầu
**Assignee**: Nguyễn Hoài Ân (CE190990) · **Thời gian**: 22/10/2026 – 29/10/2026

- [ ] **[Presentation]** Màn hình / BottomSheet viết đánh giá sản phẩm sau khi đơn hàng chuyển sang trạng thái "Đã hoàn thành".
- [ ] **[Interactive Form]** Bộ chọn số sao đánh giá (Star rating tương tác), ô nhập cảm nhận nhận xét, nút tải đính kèm hình ảnh thực tế.
- [ ] **[API Integration]** Gọi `POST /api/products/{id}/reviews`, gửi payload đánh giá lên server và cập nhật lại điểm đánh giá.
