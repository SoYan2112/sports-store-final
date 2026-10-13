# Phân Công Nhiệm Vụ 5 Thành Viên (Team Assignment & Matrix)
## Dự án: sports-store-mobile

Phân công theo mô hình **Feature / Domain Owner**: Mỗi thành viên chịu trách nhiệm End-to-End cho mảng tính năng của mình (từ UI, BLoC State Management, Tích hợp API đến Unit Test), đồng thời hỗ trợ kiểm thử chéo (Cross-testing) và Code Review.

---

### Tổng quan Vai trò 5 Thành viên

| Thành viên | Mã SV | Vai trò chính (Domain Owner) | Trách nhiệm cốt lõi |
| :--- | :--- | :--- | :--- |
| **Nguyễn Hoài Ân** | CE190990 | **Core Foundation & Authentication** | Setup dự án, Clean Architecture, Network/Dio Interceptors, Auth (Login/Register/Token Cache) |
| **Trần Hoàng Nhật** | CE190581 | **Product Catalog & Discovery** | Giao diện phong cách Adidas, Danh sách Sản phẩm, Lọc đa tiêu chí, Phân trang vô tận, Chi tiết sản phẩm & Tìm kiếm |
| **Nguyễn Minh Nhật** | CE191491 | **Cart, Checkout & Vietnam Payment** | Giỏ hàng (CartBloc), Tính tổng tiền VNĐ, Checkout, Tích hợp COD & Cổng thanh toán (VNPAY/MoMo), Đặt hàng |
| **Thái San Yo** | CE190435 | **Profile, Vietnam Address & Retention** | Sổ địa chỉ 3 cấp Việt Nam, Thông tin cá nhân, Hệ thống Voucher/Mã giảm giá, Đánh giá & Rating sản phẩm |
| **Ngô Nhất Quý** | CE190984 | **Admin Operations & QA/Testing** | Phân hệ Admin (Quản lý Sản phẩm, Danh mục, Duyệt đơn), Widget Test, Audit lỗi và tối ưu hiệu năng toàn app |

---

### Phân công UC Theo Thành viên

#### Nguyễn Hoài Ân (CE190990) — Core Foundation & Auth
- **Sprint 1**: UC-01 (Login)
- **Backlog P1**: UC-26 (View profile), UC-27 (Edit profile)

#### Trần Hoàng Nhật (CE190581) — Product Catalog & Discovery
- **Sprint 1**: UC-02 (Register)
- **Sprint 2**: UC-07 (View product categories)
- **Backlog P1**: UC-19 (Search products), UC-20 (Filter products)

#### Nguyễn Minh Nhật (CE191491) — Cart, Checkout & Payment
- **Sprint 1**: UC-03 (Logout), UC-06 (Select size/color variant)
- **Sprint 2**: UC-08 (Add to cart), UC-09 (View cart), UC-10 (Update quantity), UC-11 (Remove item)
- **Sprint 3**: UC-13 (Review order summary), UC-14 (Place order), UC-15 (Select COD)

#### Thái San Yo (CE190435) — Profile, Address & Voucher
- **Sprint 1**: UC-04 (View product list)
- **Sprint 3**: UC-12 (Select shipping address), UC-16 (View order history), UC-17 (View order details)
- **Backlog P1**: UC-21 (Add address), UC-22 (Edit address), UC-23 (Delete address), UC-24 (Cancel order), UC-25 (Track order)

#### Ngô Nhất Quý (CE190984) — Admin & QA
- **Sprint 1**: UC-05 (View product details)
- **Backlog P1**: (Testing & QA support across all sprints)
- **Backlog P2**: UC-30 → UC-36 (Reviews, Notifications, Return, Support)

---

### Quy Trình Git & Phối Hợp Làm Việc (Workflow Rules)

1. **Quy tắc phân nhánh (Branching Convention)**:
   - Nhánh chính: `main` (mã nguồn ổn định phát hành), `develop` (mã nguồn tích hợp của các sprint).
   - Nhánh tính năng: `feature/UC-[ID]-[ten-tinh-nang]` (Ví dụ: `feature/UC-01-login`).
   - Nhánh sửa lỗi: `bugfix/UC-[ID]-[ten-loi]`.
2. **Quy tắc Pull Request (PR)**:
   - Mỗi PR phải đính kèm mã UC ID tương ứng.
   - Bắt buộc có ít nhất **1 thành viên khác duyệt (Code Review)** trước khi merge vào `develop`.
   - Tất cả các lệnh `flutter test` và `flutter analyze` phải pass 100% không có lỗi nghiêm trọng.
