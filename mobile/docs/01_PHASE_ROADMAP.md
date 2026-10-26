# Kế hoạch Lộ trình 3 Sprint (Product Roadmap)
## Dự án: sports-store-mobile (Multi-brand Sports Store)

Lộ trình dự án được chuẩn hóa theo danh mục **24 Use Cases** (tổng 39 Story Points), chia làm 3 Sprint rõ ràng bảo đảm tiến độ phát triển song song của 5 thành viên không bị phụ thuộc chéo.

---

### 📊 Thống kê Tổng quan Lộ trình

| Giai đoạn | Thời gian | Số Use Cases | Tổng Story Points | Trọng tâm cốt lõi | Trạng thái |
| :--- | :--- | :---: | :---: | :--- | :--- |
| **Sprint 1** | 11/10/2026 – 13/10/2026 | 7 UCs (UC-01 → UC-07) | 12 pts | Nền tảng Auth, Core Product Catalog, Variant & Home Layout | ✅ Hoàn thành (7/7 Done, 12/12 pts) |
| **Sprint 2** | 14/10/2026 – 21/10/2026 | 7 UCs (UC-08 → UC-14) | 10 pts | Giỏ hàng, Đặt hàng, Tìm kiếm, Sổ địa chỉ & Lịch sử đơn | ⏳ Đang thực hiện (4 Done, 3 In Progress, 5/10 pts) |
| **Sprint 3** | 22/10/2026 – 29/10/2026 | 10 UCs (UC-15 → UC-24) | 17 pts | Chi tiết đơn, Hủy đơn, Lọc, Voucher & Đánh giá sản phẩm | ⏳ Đang thực hiện (4 Done, 2 In Progress, 4 Not Yet, 6/17 pts) |
| **TỔNG CỘNG**| **3 tuần** | **24 UCs** | **39 pts** | **Hoàn chỉnh luồng E-commerce thể thao chuẩn Việt Nam** | **Tiến độ chung: 15/24 UCs (23/39 pts ~59.0%)** |

---

### 🏃 SPRINT 1: Nền tảng Xác thực, Danh mục Sản phẩm & Home Layout
- **Thời gian**: 11/10/2026 – 13/10/2026
- **Tổng điểm**: 12 Story Points
- **Mục tiêu**: Chuẩn hóa Clean Architecture, cơ chế Lazy Login, trải nghiệm duyệt sản phẩm Grid 2 cột, biến thể size/màu và khung giao diện Trang chủ (MainLayoutScreen + HomeScreen).

#### Danh sách Use Cases:
1. **UC-01 · Login** (P0 · Medium · 2 pts) — Nguyễn Hoài Ân (CE190990) — [feat/login](https://github.com/SoYan2112/sports-store-final/tree/feat/login) — ✅ **Done**
2. **UC-02 · Register** (P0 · Medium · 2 pts) — Trần Hoàng Nhật (CE190581) — [feat/register](https://github.com/SoYan2112/sports-store-final/tree/feat/register) — ✅ **Done**
3. **UC-03 · Logout** (P0 · Simple · 1 pt) — Nguyễn Minh Nhật (CE191491) — [feat/logout](https://github.com/SoYan2112/sports-store-final/tree/feat/logout) — ✅ **Done**
4. **UC-04 · View product list** (P0 · Simple · 1 pt) — Thái San Yo (CE190435) — ✅ **Done**
5. **UC-05 · View product details** (P0 · Medium · 2 pts) — Ngô Nhất Quý (CE190984) — ✅ **Done**
6. **UC-06 · Select product variant** (P0 · Complex · 3 pts) — Nguyễn Minh Nhật (CE191491) — ✅ **Done**
7. **UC-07 · Home layout** (P1 · Simple · 1 pt) — Thái San Yo (CE190435) — [feat/home-layout](https://github.com/SoYan2112/sports-store-final/commit/8ae3a4c5677629c151cebb39f520ff7f77bc1e33) — ✅ **Done**

---

### 🛒 SPRINT 2: Giỏ hàng, Đặt hàng, Tìm kiếm & Địa chỉ giao hàng
- **Thời gian**: 14/10/2026 – 21/10/2026
- **Tổng điểm**: 10 Story Points
- **Tiến độ**: 4/7 Done (5/10 pts)
- **Mục tiêu**: Hoàn thiện phễu mua sắm: Thêm sản phẩm vào giỏ, điều chỉnh số lượng, tạo địa chỉ giao hàng Việt Nam, thanh toán COD và theo dõi lịch sử đơn hàng.

#### Danh sách Use Cases:
8. **UC-08 · Order items** (P0 · Complex · 3 pts) — Thái San Yo (CE190435) — [feat/order-items](https://github.com/SoYan2112/sports-store-final/tree/feat/order-items) — ⏳ **In progress** *(Ân hoàn thành screen success, commit lên branch)*
9. **UC-09 · Search products by keyword** (P1 · Simple · 1 pt) — Ngô Nhất Quý (CE190984) — [feat/search-products-by-keyword](https://github.com/SoYan2112/sports-store-final/tree/feat/search-products-by-keyword) — ✅ **Done**
10. **UC-10 · Add shipping address** (P1 · Medium · 2 pts) — Trần Hoàng Nhật (CE190581) — [feat/add-shipping-address](https://github.com/SoYan2112/sports-store-final/tree/feat/add-shipping-address) — ✅ **Done**
11. **UC-11 · Add product to cart** (P0 · Simple · 1 pt) — Thái San Yo (CE190435) — ⏳ **In progress**
12. **UC-12 · View shopping cart** (P0 · Simple · 1 pt) — Thái San Yo (CE190435) — ⏳ **In progress**
13. **UC-13 · Remove item from cart** (P0 · Simple · 1 pt) — Thái San Yo (CE190435) — ⏳ **In progress**
14. **UC-14 · View order history** (P0 · Simple · 1 pt) — Nguyễn Hoài Ân (CE190990) — [feat/view-order-history](https://github.com/SoYan2112/sports-store-final/tree/feat/view-order-history) — ✅ **Done**

---

### 📦 SPRINT 3: Quản lý Đơn hàng nâng cao, Bộ lọc, Voucher & Đánh giá
- **Thời gian**: 22/10/2026 – 29/10/2026
- **Tổng điểm**: 17 Story Points
- **Mục tiêu**: Xem chi tiết đơn hàng, xử lý hủy đơn đủ điều kiện, lọc sản phẩm đa tiêu chí, CRUD sổ địa chỉ giao hàng, kho voucher, áp dụng voucher và đánh giá sản phẩm.

#### Danh sách Use Cases:
15. **UC-15 · View order details** (P0 · Medium · 2 pts) — Nguyễn Hoài Ân (CE190990) — ⏹ **Not yet**
16. **UC-16 · View product categories** (P0 · Simple · 1 pt) — Nguyễn Minh Nhật (CE191491) — [feat/view-product-categories](https://github.com/SoYan2112/sports-store-final/tree/feat/view-product-categories) — ⏳ **In progress**
17. **UC-17 · Filter products** (P1 · Medium · 2 pts) — Ngô Nhất Quý (CE190984) — [feat/filter-products](https://github.com/SoYan2112/sports-store-final/tree/feat/filter-products) — ✅ **Done**
18. **UC-18 · Edit shipping address** (P1 · Medium · 2 pts) — Trần Hoàng Nhật (CE190581) — [feat/edit-shipping-address](https://github.com/SoYan2112/sports-store-final/tree/feat/edit-shipping-address) — ✅ **Done**
19. **UC-19 · Delete shipping address** (P1 · Simple · 1 pt) — Trần Hoàng Nhật (CE190581) — [feat/delete-shipping-address](https://github.com/SoYan2112/sports-store-final/tree/feat/delete-shipping-address) — ✅ **Done**
20. **UC-20 · Cancel order** (P1 · Complex · 3 pts) — Ngô Nhất Quý (CE190984) — ⏳ **In progress**
21. **UC-21 · View voucher list** (P1 · Simple · 1 pt) — Nguyễn Minh Nhật (CE191491) — [feat/view-voucher-list](https://github.com/SoYan2112/sports-store-final/tree/feat/view-voucher-list) — ✅ **Done**
22. **UC-22 · Apply voucher** (P1 · Medium · 2 pts) — Nguyễn Minh Nhật (CE191491) — ⏹ **Not yet**
23. **UC-23 · View product rating** (P1 · Simple · 1 pt) — Nguyễn Hoài Ân (CE190990) — ⏹ **Not yet**
24. **UC-24 · Add product rating** (P2 · Medium · 2 pts) — Nguyễn Hoài Ân (CE190990) — ⏹ **Not yet**
