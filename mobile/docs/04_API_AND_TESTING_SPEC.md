# Đặc Tả API & Kiểm Thử (API Specification & Testing)
## Dự án: sports-store-mobile

---

### 1. Base URL & Authentication

```
Base URL: https://api.sportsstore.vn/api/v1
Authentication: Bearer Token (JWT)
Header: Authorization: Bearer {accessToken}
```

---

### 2. Authentication Endpoints

| Method | Endpoint | Mô tả | UC |
|:---:|:---|:---|:---:|
| POST | `/auth/login` | Đăng nhập, trả về accessToken & refreshToken | UC-01 |
| POST | `/auth/register` | Đăng ký tài khoản mới | UC-02 |
| POST | `/auth/logout` | Vô hiệu hóa token | UC-03 |
| POST | `/auth/refresh` | Làm mới accessToken bằng refreshToken | — |

---

### 3. Product Endpoints

| Method | Endpoint | Mô tả | UC |
|:---:|:---|:---|:---:|
| GET | `/products?page=&size=&categoryId=&keyword=&minPrice=&maxPrice=` | Lấy danh sách sản phẩm có phân trang & lọc | UC-04, UC-20 |
| GET | `/products/{id}` | Chi tiết một sản phẩm | UC-05 |
| GET | `/products/{id}/variants` | Lấy danh sách biến thể (size, màu) | UC-06 |
| GET | `/categories` | Danh sách danh mục thể thao | UC-07 |
| GET | `/products?keyword={q}` | Tìm kiếm sản phẩm theo từ khóa | UC-19 |
| GET | `/products/{id}/reviews` | Lấy danh sách đánh giá của sản phẩm | UC-30, UC-31 |

---

### 4. Cart Endpoints

| Method | Endpoint | Mô tả | UC |
|:---:|:---|:---|:---:|
| GET | `/cart` | Lấy giỏ hàng hiện tại của user | UC-09 |
| POST | `/cart/items` | Thêm sản phẩm vào giỏ | UC-08 |
| PUT | `/cart/items/{id}` | Cập nhật số lượng item | UC-10 |
| DELETE | `/cart/items/{id}` | Xóa item khỏi giỏ | UC-11 |

---

### 5. Order & Checkout Endpoints

| Method | Endpoint | Mô tả | UC |
|:---:|:---|:---|:---:|
| POST | `/orders` | Tạo đơn hàng mới | UC-14 |
| GET | `/orders?status=` | Lịch sử đơn hàng theo trạng thái | UC-16 |
| GET | `/orders/{id}` | Chi tiết đơn hàng | UC-17 |
| PATCH | `/orders/{id}/cancel` | Hủy đơn hàng | UC-24 |
| POST | `/orders/{id}/return` | Yêu cầu hoàn trả | UC-35 |

---

### 6. Address Endpoints

| Method | Endpoint | Mô tả | UC |
|:---:|:---|:---|:---:|
| GET | `/addresses` | Lấy sổ địa chỉ của user | UC-12 |
| POST | `/addresses` | Thêm địa chỉ mới | UC-21 |
| PUT | `/addresses/{id}` | Cập nhật địa chỉ | UC-22 |
| DELETE | `/addresses/{id}` | Xóa địa chỉ | UC-23 |
| GET | `/provinces` | Danh mục Tỉnh/Thành VN | UC-21 |
| GET | `/provinces/{id}/districts` | Quận/Huyện theo Tỉnh | UC-21 |
| GET | `/districts/{id}/wards` | Phường/Xã theo Quận | UC-21 |

---

### 7. User Profile Endpoints

| Method | Endpoint | Mô tả | UC |
|:---:|:---|:---|:---:|
| GET | `/users/me` | Lấy thông tin profile | UC-26 |
| PUT | `/users/me` | Cập nhật thông tin profile | UC-27 |

---

### 8. Wishlist & Review Endpoints

| Method | Endpoint | Mô tả | UC |
|:---:|:---|:---|:---:|
| GET | `/wishlist` | Lấy danh sách yêu thích | UC-29 |
| POST | `/wishlist/{productId}` | Thêm vào wishlist | UC-28 |
| DELETE | `/wishlist/{productId}` | Xóa khỏi wishlist | UC-28 |
| POST | `/reviews` | Gửi đánh giá sản phẩm | UC-32 |

---

### 9. Miscellaneous Endpoints

| Method | Endpoint | Mô tả | UC |
|:---:|:---|:---|:---:|
| GET | `/banners` | Lấy danh sách banner trang chủ | UC-18 |
| GET | `/notifications` | Lịch sử thông báo | UC-34 |
| POST | `/support` | Gửi yêu cầu hỗ trợ | UC-36 |

---

### 10. Chiến lược Kiểm thử (Testing Strategy)

#### Unit Test (BLoC/Cubit)
Sử dụng `bloc_test` + `mocktail`:
```dart
blocTest<AuthBloc, AuthState>(
  'emits AuthSuccess when login succeeds',
  build: () => AuthBloc(authRepository: mockAuthRepository),
  act: (bloc) => bloc.add(LoginEvent(email: 'test@email.com', password: '123456')),
  expect: () => [AuthLoading(), AuthSuccess(user: mockUser)],
);
```

#### Widget Test
Sử dụng `flutter_test` + `WidgetTester`:
- Kiểm tra `LoginScreen` render đúng các field.
- Kiểm tra `ProductCard` hiển thị đúng giá VNĐ.
- Kiểm tra `CartScreen` cập nhật tổng tiền khi thay đổi số lượng.

#### Acceptance Criteria chung
- Tất cả API calls phải có timeout xử lý (>10s → báo lỗi tiếng Việt).
- Giá tiền luôn định dạng: `1.950.000 ₫`.
- SĐT validate theo regex: `^(0|\+84)(3|5|7|8|9)\d{8}$`.
- Token hết hạn → tự động refresh, nếu refresh fail → logout.
