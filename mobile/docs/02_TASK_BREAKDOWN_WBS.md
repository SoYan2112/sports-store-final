# Kế Hoạch Thực Thi Theo Use Case (UC Execution Plan)
## Dự án: sports-store-mobile

Tài liệu này là kế hoạch thực thi chính thức, trình bày **từng Use Case (UC)** như một deliverable độc lập, ánh xạ trực tiếp vào kiến trúc **Feature-First Clean Architecture** với **BLoC/Cubit** trên Flutter.

> **Phạm vi**: Mobile (Flutter/Dart) — Backend sẽ được bổ sung riêng.
> **Độ chi tiết**: 3–5 sub-task Mobile mỗi UC.

---

## 📌 SPRINT 1 — Foundation & Authentication
**Tiến độ**: 🔄 Đang thực hiện (2/9 pts · 22%)

---

### UC-01 · Login · `P0` · Medium · 2 pts
**Assignee**: Nguyễn Hoài Ân (CE190990)

- **[Mobile]** Dựng `LoginScreen` với `AppTextField` email/SĐT + password, nút CTA kiểu Adidas (nền đen, chữ trắng).
- **[Mobile]** Viết `AuthBloc` xử lý `LoginEvent` → emit `AuthLoading`, `AuthSuccess`, `AuthFailure`.
- **[Mobile]** Tạo `AuthRemoteDataSource.login()` gọi `POST /api/auth/login` qua Dio, parse response thành `AuthTokenModel`.
- **[Mobile]** Lưu `accessToken` + `refreshToken` vào `SharedPreferences` sau login thành công.
- **[Mobile]** Điều hướng tự động về `HomeScreen` khi phiên token còn hợp lệ lúc khởi động app.

---

### UC-02 · Register · `P0` · Medium · 2 pts
**Assignee**: Trần Hoàng Nhật (CE190581)

- **[Mobile]** Dựng `RegisterScreen` với các field: Họ tên, Email, SĐT (validate chuẩn VN: `09x/03x/07x/08x`), Mật khẩu ≥ 6 ký tự.
- **[Mobile]** Tái dùng `AuthBloc` hoặc tạo `RegisterCubit` emit `RegisterLoading`, `RegisterSuccess`, `RegisterFailure`.
- **[Mobile]** Tạo `AuthRemoteDataSource.register()` gọi `POST /api/auth/register`.
- **[Mobile]** Hiển thị lỗi validation inline ngay dưới từng field (không dùng dialog).
- **[Mobile]** Sau đăng ký thành công → tự động đăng nhập và điều hướng sang `HomeScreen`.

---

### UC-03 · Logout · `P0` · Simple · 0.5 pts
**Assignee**: Nguyễn Minh Nhật (CE191491)

- **[Mobile]** Thêm menu Logout vào `ProfileScreen` hoặc AppBar Drawer.
- **[Mobile]** Dispatch `LogoutEvent` trong `AuthBloc` → xóa toàn bộ token khỏi `SharedPreferences`.
- **[Mobile]** Reset navigation stack → điều hướng về `LoginScreen` (không cho back bằng nút back vật lý).

---

### UC-04 · View product list · `P0` · Medium · 2 pts · ✅ Hoàn thành
**Assignee**: Thái San Yo (CE190435)

- [x] **[Mobile]** Dựng `ProductListScreen` dạng Grid 2 cột với `ProductCard` (ảnh 3:4, tên, giá VNĐ, badge).
- [x] **[Mobile]** Viết `ProductBloc` xử lý `FetchProductsEvent` → emit `ProductLoading`, `ProductLoaded`, `ProductError`.
- [x] **[Mobile]** Tạo `ProductRemoteDataSource.getProducts()` gọi `GET /api/products` với hỗ trợ phân trang (`page`, `size`).
- [x] **[Mobile]** Implement Infinite Scroll: trigger `FetchMoreProductsEvent` khi `ScrollController` gần cuối danh sách.
- [x] **[Mobile]** Hiển thị `ProductCardSkeleton` trong lúc loading lần đầu.

---

### UC-05 · View product details · `P0` · Medium · 2 pts
**Assignee**: Ngô Nhất Quý (CE190984)

- **[Mobile]** Dựng `ProductDetailScreen` với Image Gallery (PageView/carousel), tên sản phẩm, giá VNĐ, mô tả.
- **[Mobile]** Tạo `ProductDetailCubit` gọi `GET /api/products/{id}` và emit `ProductDetailLoaded`.
- **[Mobile]** Hiển thị thông tin chi tiết: thương hiệu, danh mục, số lượng còn lại, điểm đánh giá trung bình.
- **[Mobile]** Nút "Thêm vào giỏ" nổi bật ở cuối màn hình (sticky BottomBar).

---

### UC-06 · Select product size/color variant · `P0` · Medium · 1.5 pts
**Assignee**: Nguyễn Minh Nhật (CE191491)

- **[Mobile]** Thêm widget chọn Size (dạng chip/grid ngang: 36, 37, 38...) vào `ProductDetailScreen`.
- **[Mobile]** Thêm widget chọn Màu sắc (color dot selector) liên kết với biến thể sản phẩm (`ProductVariant`).
- **[Mobile]** Disable nút "Thêm vào giỏ" nếu chưa chọn đủ Size + Màu.
- **[Mobile]** Cập nhật `ProductDetailCubit` để track `selectedSize` và `selectedColor` vào state.
- **[Mobile]** Đánh dấu size hết hàng (`outOfStock`) bằng style strikethrough + màu xám.

---

## 📌 SPRINT 2 — Product Discovery & Cart
**Tiến độ**: ⏹ Chưa bắt đầu

---

### UC-07 · View product categories · `P0` · Medium · 1.5 pts

- **[Mobile]** Dựng `CategoryListScreen` hoặc tích hợp vào `HomeScreen` dạng horizontal scroll chip.
- **[Mobile]** Viết `CategoryCubit` gọi `GET /api/categories` và emit `CategoryLoaded`.
- **[Mobile]** Khi chọn danh mục → điều hướng sang `ProductListScreen` với filter `categoryId` truyền qua route.
- **[Mobile]** Hiển thị icon/ảnh đại diện từng danh mục thể thao (Bóng đá, Chạy bộ, Gym...).

---

### UC-08 · Add product to cart · `P0` · Medium · 1.5 pts

- **[Mobile]** Xử lý sự kiện bấm "Thêm vào giỏ" từ `ProductDetailScreen` → dispatch `AddToCartEvent`.
- **[Mobile]** `CartBloc` nhận `AddToCartEvent`: nếu sản phẩm + variant đã có → tăng `quantity`; chưa có → thêm mới.
- **[Mobile]** Gọi `POST /api/cart/items` để đồng bộ giỏ hàng lên server.
- **[Mobile]** Cập nhật badge số lượng trên icon Cart ở AppBar tức thì.
- **[Mobile]** Hiển thị SnackBar xác nhận "Đã thêm vào giỏ hàng" với nút "Xem giỏ".

---

### UC-09 · View shopping cart · `P0` · Simple · 1 pt

- **[Mobile]** Dựng `CartScreen` hiển thị danh sách `CartItem` (ảnh, tên, size, màu, giá, số lượng).
- **[Mobile]** Cuối màn hình: tổng tiền hàng (VNĐ), nút "Tiến hành thanh toán".
- **[Mobile]** Hiển thị empty state với minh họa và nút "Tiếp tục mua sắm" khi giỏ trống.
- **[Mobile]** `CartBloc` emit `CartLoaded` với danh sách items từ `GET /api/cart`.

---

### UC-10 · Update item quantity · `P0` · Medium · 1 pt

- **[Mobile]** Thêm nút `+` / `-` bên cạnh mỗi `CartItem` trong `CartScreen`.
- **[Mobile]** Dispatch `UpdateQuantityEvent(itemId, newQty)` → `CartBloc` cập nhật state và gọi `PUT /api/cart/items/{id}`.
- **[Mobile]** Tự động xóa item khi `quantity` giảm xuống 0 (với xác nhận).
- **[Mobile]** Cập nhật lại tổng tiền tức thì sau mỗi thay đổi số lượng.

---

### UC-11 · Remove item from cart · `P0` · Simple · 0.5 pts

- **[Mobile]** Thêm nút xóa (icon trash) trên mỗi `CartItem`.
- **[Mobile]** Dispatch `RemoveFromCartEvent(itemId)` → `CartBloc` xóa item khỏi state và gọi `DELETE /api/cart/items/{id}`.
- **[Mobile]** Hiển thị SnackBar với tùy chọn "Hoàn tác" (Undo) trong 3 giây.

---

## 📌 SPRINT 3 — Checkout, Orders & Profile
**Tiến độ**: ⏹ Chưa bắt đầu

---

### UC-12 · Select shipping address · `P0` · Medium · 1.5 pts

- **[Mobile]** Dựng `AddressPickerScreen` hiển thị danh sách địa chỉ đã lưu của user.
- **[Mobile]** Cho phép chọn địa chỉ mặc định hoặc thêm địa chỉ mới (điều hướng sang UC-21).
- **[Mobile]** Truyền `selectedAddress` vào `CheckoutCubit` / `OrderState`.
- **[Mobile]** Hiển thị địa chỉ được chọn ở tóm tắt checkout với tên người nhận + SĐT + địa chỉ đầy đủ 3 cấp.

---

### UC-13 · Review order summary · `P0` · Medium · 1.5 pts

- **[Mobile]** Dựng `CheckoutScreen` với tóm tắt: danh sách sản phẩm, địa chỉ giao, phương thức thanh toán, phí ship, tổng.
- **[Mobile]** `CheckoutCubit` tổng hợp state từ `CartBloc`, `AddressCubit`, `VoucherCubit`.
- **[Mobile]** Hiển thị từng khoản chi tiết: Tạm tính, Giảm giá (voucher), Phí vận chuyển, **Tổng thanh toán** (tất cả định dạng VNĐ).
- **[Mobile]** Validate không cho tiến hành nếu thiếu địa chỉ hoặc phương thức thanh toán.

---

### UC-14 · Place order · `P0` · Complex · 3 pts

- **[Mobile]** Nút "Đặt hàng" → dispatch `PlaceOrderEvent` trong `OrderBloc`.
- **[Mobile]** `OrderBloc` gọi `POST /api/orders` với payload đầy đủ (items, addressId, paymentMethod, voucherId).
- **[Mobile]** Sau khi nhận response thành công → xóa toàn bộ items trong `CartBloc`.
- **[Mobile]** Điều hướng sang `OrderSuccessScreen` hiển thị mã đơn hàng và tóm tắt.
- **[Mobile]** Xử lý lỗi: timeout, server error → dialog retry; payment failure → thông báo rõ lý do.

---

### UC-15 · Select Cash on Delivery · `P0` · Medium · 1 pt

- **[Mobile]** Dựng widget `PaymentMethodSelector` trong `CheckoutScreen` với radio button COD.
- **[Mobile]** Khi chọn COD → cập nhật `CheckoutCubit` với `paymentMethod: PaymentMethod.cod`.
- **[Mobile]** Hiển thị thông tin hướng dẫn COD: "Thanh toán khi nhận hàng — không cần thẻ ngân hàng".

---

### UC-16 · View order history · `P0` · Medium · 1.5 pts

- **[Mobile]** Dựng `OrderHistoryScreen` với tab bar 5 trạng thái: Tất cả / Chờ xác nhận / Đang giao / Hoàn thành / Đã hủy.
- **[Mobile]** Viết `OrderBloc` gọi `GET /api/orders` (có filter `status`) và emit `OrderHistoryLoaded`.
- **[Mobile]** Mỗi `OrderCard` hiển thị: mã đơn, ngày đặt, tổng tiền VNĐ, trạng thái badge.
- **[Mobile]** Bấm vào đơn → điều hướng sang `OrderDetailScreen` (UC-17).

---

### UC-17 · View order details · `P0` · Medium · 1.5 pts

- **[Mobile]** Dựng `OrderDetailScreen` hiển thị đầy đủ: sản phẩm, số lượng, giá, địa chỉ giao, phương thức thanh toán.
- **[Mobile]** `OrderDetailCubit` gọi `GET /api/orders/{orderId}` và emit `OrderDetailLoaded`.
- **[Mobile]** Hiển thị timeline trạng thái đơn hàng (Stepper widget).
- **[Mobile]** Nút hành động tùy theo trạng thái: "Hủy đơn" (nếu UC-24 eligible), "Đánh giá" (nếu Hoàn thành).

---

## 📌 BACKLOG — P1 Features (Chưa gán Sprint)

---

### UC-18 · View home banners · `P1` · Medium · 2 pts

- **[Mobile]** Tích hợp `HomeBannerCarousel` trong `HomeScreen` dùng `PageView` + AutoScrollTimer.
- **[Mobile]** `HomeCubit` gọi `GET /api/banners` và emit danh sách `BannerModel`.
- **[Mobile]** Hiển thị chấm chỉ thị slide (dots indicator) và badge khuyến mãi neon.
- **[Mobile]** Bấm banner → điều hướng đến `ProductListScreen` với filter từ `banner.targetRoute`.

---

### UC-19 · Search products by keyword · `P1` · Medium · 2 pts

- **[Mobile]** Dựng `SearchScreen` với `SearchTextField` có debounce 500ms.
- **[Mobile]** `SearchBloc` lắng nghe `SearchQueryChanged` → gọi `GET /api/products?keyword={q}`.
- **[Mobile]** Hiển thị lịch sử tìm kiếm gần đây (lưu vào `SharedPreferences`), xóa từng mục hoặc xóa tất cả.
- **[Mobile]** Kết quả hiển thị dạng List với highlight từ khóa khớp.

---

### UC-20 · Filter products by price/category · `P1` · Complex · 2.5 pts

- **[Mobile]** Dựng `FilterBottomSheet` với: khoảng giá (RangeSlider VNĐ), danh mục (checkbox), giới tính (radio), hãng (checkbox).
- **[Mobile]** `ProductBloc` nhận `ApplyFilterEvent` → emit `ProductFiltered` và gọi lại API với query params filter.
- **[Mobile]** Hiển thị chip filter active ở trên danh sách sản phẩm, bấm xóa từng filter.
- **[Mobile]** Nút "Đặt lại" reset toàn bộ bộ lọc về mặc định.

---

### UC-21 · Add shipping address · `P1` · Medium · 1.5 pts

- **[Mobile]** Dựng `AddAddressScreen` với form: Họ tên, SĐT, Tỉnh/Thành → Quận/Huyện → Phường/Xã (cascade dropdown 3 cấp), Số nhà/đường, checkbox "Đặt làm mặc định".
- **[Mobile]** Dữ liệu hành chính VN từ JSON local hoặc `GET /api/provinces`.
- **[Mobile]** `AddressCubit` gọi `POST /api/addresses` và emit `AddressAdded`.
- **[Mobile]** Validate SĐT định dạng Việt Nam trước khi submit.

---

### UC-22 · Edit shipping address · `P1` · Medium · 1 pt

- **[Mobile]** Tái sử dụng `AddAddressScreen` ở chế độ edit, pre-fill toàn bộ dữ liệu địa chỉ hiện có.
- **[Mobile]** `AddressCubit` gọi `PUT /api/addresses/{id}` và emit `AddressUpdated`.
- **[Mobile]** Cập nhật lại danh sách địa chỉ trong `AddressListScreen` tức thì.

---

### UC-23 · Delete shipping address · `P1` · Simple · 0.5 pts

- **[Mobile]** Thêm nút xóa (swipe-to-delete hoặc icon) trên từng địa chỉ trong `AddressListScreen`.
- **[Mobile]** Hiển thị dialog xác nhận trước khi xóa.
- **[Mobile]** `AddressCubit` gọi `DELETE /api/addresses/{id}` và emit `AddressDeleted`.

---

### UC-24 · Cancel eligible order · `P1` · Medium · 1.5 pts

- **[Mobile]** Nút "Hủy đơn" chỉ hiển thị khi đơn ở trạng thái "Chờ xác nhận" hoặc "Đang xử lý".
- **[Mobile]** Hiển thị `CancelReasonBottomSheet` để user chọn lý do hủy.
- **[Mobile]** `OrderBloc` gọi `PATCH /api/orders/{id}/cancel` với `reason` và emit `OrderCancelled`.
- **[Mobile]** Cập nhật lại trạng thái đơn trong `OrderHistoryScreen`.

---

### UC-25 · Track order status · `P1` · Medium · 1.5 pts

- **[Mobile]** Trong `OrderDetailScreen`: hiển thị Stepper timeline các bước: Đặt hàng → Xác nhận → Đóng gói → Đang giao → Hoàn thành.
- **[Mobile]** `OrderDetailCubit` polling `GET /api/orders/{id}` mỗi 30 giây khi màn hình active.
- **[Mobile]** Mỗi bước hiển thị timestamp tương ứng.

---

### UC-26 · View profile · `P1` · Simple · 1 pt

- **[Mobile]** Dựng `ProfileScreen` hiển thị: Avatar, Họ tên, Email, SĐT, các menu điều hướng (Đơn hàng, Địa chỉ, Voucher, Đánh giá, Đăng xuất).
- **[Mobile]** `ProfileCubit` gọi `GET /api/users/me` và emit `ProfileLoaded`.

---

### UC-27 · Edit profile · `P1` · Medium · 1.5 pts

- **[Mobile]** Dựng `EditProfileScreen` với field: Họ tên, SĐT, tùy chọn đổi Avatar (chọn ảnh từ gallery).
- **[Mobile]** `ProfileCubit` gọi `PUT /api/users/me` (JSON) hoặc Multipart nếu có upload ảnh.
- **[Mobile]** Emit `ProfileUpdated` → cập nhật lại `ProfileScreen` tức thì.

---

## 📌 BACKLOG — P2 Features (Chưa gán Sprint)

---

### UC-28 · Add product to wishlist · `P2` · Medium · 1 pt

- **[Mobile]** Thêm icon tim (❤) trên `ProductCard` và `ProductDetailScreen`.
- **[Mobile]** `WishlistCubit` toggle: gọi `POST /api/wishlist/{productId}` hoặc `DELETE` nếu đã thêm.
- **[Mobile]** Cập nhật icon tim tức thì (optimistic update) không chờ server response.

---

### UC-29 · View wishlist · `P2` · Simple · 1 pt

- **[Mobile]** Dựng `WishlistScreen` hiển thị danh sách sản phẩm đã thả tim.
- **[Mobile]** `WishlistCubit` gọi `GET /api/wishlist` và emit `WishlistLoaded`.
- **[Mobile]** Mỗi item có nút "Thêm vào giỏ" và nút xóa khỏi wishlist.
- **[Mobile]** Empty state thân thiện khi wishlist trống.

---

### UC-30 · View product ratings and reviews · `P2` · Medium · 1.5 pts

- **[Mobile]** Trong `ProductDetailScreen`: hiển thị điểm trung bình (sao 1–5), phân bố rating (thanh bar), số lượt đánh giá.
- **[Mobile]** `ReviewCubit` gọi `GET /api/products/{id}/reviews` và emit `ReviewsLoaded`.
- **[Mobile]** Hỗ trợ phân trang lazy-load cho danh sách review.

---

### UC-31 · View product reviews and ratings · `P2` · Medium · 1.5 pts

- **[Mobile]** Dựng `ReviewListScreen` (hoặc tab trong `ProductDetailScreen`) hiển thị từng review: tên user, sao, nội dung, ảnh đính kèm, ngày.
- **[Mobile]** Bộ lọc review theo số sao (1★ → 5★) và theo "Có ảnh".
- **[Mobile]** `ReviewCubit` hỗ trợ `FilterReviewsEvent(starCount)`.

---

### UC-32 · Submit rating and review · `P2` · Medium · 2 pts

- **[Mobile]** Dựng `RatingFormScreen` chỉ mở được khi đơn hàng ở trạng thái "Hoàn thành".
- **[Mobile]** Widget chọn sao (1–5), field nhập nội dung nhận xét, tùy chọn đính kèm ảnh.
- **[Mobile]** `ReviewCubit` gọi `POST /api/reviews` (Multipart nếu có ảnh) và emit `ReviewSubmitted`.
- **[Mobile]** Sau khi gửi thành công → tự cập nhật lại điểm trung bình ở `ProductDetailScreen`.

---

### UC-33 · Receive order status push notifications · `P2` · Complex · 3 pts

- **[Mobile]** Tích hợp `firebase_messaging` (FCM) hoặc `flutter_local_notifications`.
- **[Mobile]** Xử lý payload notification khi app ở foreground, background và terminated.
- **[Mobile]** Bấm notification → deep-link đến `OrderDetailScreen` với `orderId` tương ứng.
- **[Mobile]** Hiển thị banner in-app khi đơn thay đổi trạng thái trong lúc user đang dùng app.

---

### UC-34 · View notification history · `P2` · Medium · 1.5 pts

- **[Mobile]** Dựng `NotificationScreen` hiển thị lịch sử thông báo (từ `GET /api/notifications`).
- **[Mobile]** `NotificationCubit` emit `NotificationsLoaded`, đánh dấu "đã đọc" khi bấm vào.
- **[Mobile]** Badge số thông báo chưa đọc hiển thị trên icon bell ở AppBar.

---

### UC-35 · Request return / refund · `P2` · Complex · 3 pts

- **[Mobile]** Nút "Yêu cầu hoàn trả" chỉ xuất hiện khi đơn ở trạng thái "Hoàn thành" trong vòng X ngày.
- **[Mobile]** Dựng `ReturnRequestScreen`: chọn sản phẩm cần trả, lý do (dropdown), mô tả, đính kèm ảnh bằng chứng.
- **[Mobile]** `ReturnCubit` gọi `POST /api/orders/{id}/return` (Multipart) và emit `ReturnRequested`.
- **[Mobile]** Hiển thị trạng thái yêu cầu hoàn trả trong `OrderDetailScreen`.

---

### UC-36 · Submit support request · `P2` · Medium · 2 pts

- **[Mobile]** Dựng `SupportScreen` với form: Chủ đề (dropdown), Nội dung, đính kèm ảnh tùy chọn.
- **[Mobile]** `SupportCubit` gọi `POST /api/support` và emit `SupportSubmitted`.
- **[Mobile]** Hiển thị ticket ID sau khi gửi thành công cùng thông báo thời gian phản hồi dự kiến.
- **[Mobile]** Tùy chọn xem lịch sử ticket đã gửi.

---

## 📊 Tổng hợp thống kê

| Sprint / Backlog | UC | Story Points | Trạng thái |
|:---|:---:|:---:|:---:|
| Sprint 1 | UC-01 → UC-06 | 9 pts | ⏹ Chưa bắt đầu |
| Sprint 2 | UC-07 → UC-11 | 5.5 pts | ⏹ Chưa bắt đầu |
| Sprint 3 | UC-12 → UC-17 | 10 pts | ⏹ Chưa bắt đầu |
| Backlog P1 | UC-18 → UC-27 | 13 pts | ⏹ Chưa gán |
| Backlog P2 | UC-28 → UC-36 | 17 pts | ⏹ Chưa gán |
| **Tổng** | **36 UC** | **54.5 pts** | |
