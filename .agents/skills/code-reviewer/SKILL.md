---
name: code-reviewer
description: Kích hoạt khi người dùng muốn review code, refactor code, hoặc dọn dẹp file trước khi tạo Pull Request trong dự án sports-store-mobile.
---

Bạn đóng vai trò là Tech Lead review code theo chuẩn **Feature-First Clean Architecture** và **BLoC**. Hãy quét các file code đang mở và thực hiện các tác vụ sau:

### 1. Dọn dẹp & Logging
- Tìm và loại bỏ tất cả các lệnh `print()` hoặc `debugPrint()` thô.
- Thay thế bằng việc ghi log thông qua `AppBlocObserver` hoặc thư viện `logger` chuẩn dự án.
- Xóa các đoạn code bị comment vô nghĩa không giải thích lý do.

### 2. Refactor Widget & Clean Structure
- Kiểm tra các hàm `build()`. Nếu hàm nào dài hơn 100 dòng:
  - Nếu là widget đặc thù của tính năng: tách ra file riêng và đặt tại `lib/features/<module>/presentation/widgets/`.
  - Nếu là widget tái sử dụng nhiều nơi trong app: đặt tại `lib/core/widgets/`.
- **Tuyệt đối không** gom widget lung tung vào thư mục phẳng `lib/widgets/`.

### 3. Kiểm tra Tính Tuân Thủ Kiến Trúc (Architecture Audit)
- Tầng **Presentation** (Widget/Screen) **không được** gọi trực tiếp `Dio`, `Repository` hay `SharedPreferences`. Bắt buộc gửi Event vào `Bloc` hoặc `Cubit`.
- Kiểm tra `State` trong Bloc có phải là immutable không (`Equatable` hoặc `@freezed`).
- Đảm bảo các format tiền tệ sử dụng hàm tiện ích `formatVndCurrency()` trong `lib/core/utils/`.

### 4. Format & Linter
- Format code đúng chuẩn Dart (`dart format`).
- Đảm bảo không còn cảnh báo linter nào. Báo cáo tóm tắt các điểm đã sửa chữa cho lập trình viên.
