# Sports Store Backend - Microservices Architecture

Hệ thống Backend Microservices cho ứng dụng Sports Store được phát triển bằng **Spring Boot 3 / 4**, **Spring Cloud (Eureka, API Gateway, Config Server)**, **Microsoft SQL Server 2022**, và **Docker Compose**.

---

## 🚀 Khởi chạy toàn bộ hệ thống bằng 1 lệnh duy nhất (Docker Compose)

Yêu cầu máy tính đã cài đặt **Docker Desktop** (hoặc Docker Engine & Docker Compose).

Chạy lệnh sau tại thư mục gốc hoặc thư mục `backend/`:

```bash
docker compose up -d --build
```

### Quy trình tự động khởi tạo hệ thống:
1. `sqlserver`: Khởi động container MSSQL 2022.
2. `sqlserver-init`: Chờ cho `sqlserver` chuyển sang trạng thái `healthy`, sau đó tự động chạy script [`init-db.sql`](./init-db.sql) để:
   - Tạo 4 database: `sports_store`, `sports_store_product`, `sports_store_order`, `sports_store_voucher`.
   - Seed dữ liệu người dùng test, địa chỉ giao hàng mẫu, và các mã giảm giá voucher (`FREESHIP`, `SPORT20`, `WELCOME50`).
3. `discovery-server` (Netflix Eureka Server) và `config-server` khởi động.
4. Các microservices nghiệp vụ (`identity-service`, `product-service`, `order-service`, `voucher-service`) và `api-gateway` tự động chờ DB sẵn sàng rồi khởi chạy và đăng ký vào Eureka.
5. `prometheus` khởi động để giám sát metrics của hệ thống.

---

## 📌 Danh sách các Services và Cổng truy cập (Ports)

| Service | Port | Endpoint chính / Swagger UI | Trách nhiệm |
| :--- | :---: | :--- | :--- |
| **ApiGateway** | `8080` | `http://localhost:8080/api/v1/...` | Cổng API tập trung, định tuyến, bảo mật & fallback |
| **DiscoveryServer** | `8761` | `http://localhost:8761` | Netflix Eureka Service Registry Dashboard |
| **ConfigServer** | `8888` | `http://localhost:8888` | Spring Cloud Config Server |
| **IdentityService** | `8081` | `http://localhost:8081/swagger-ui.html` | Quản lý xác thực JWT, tài khoản, địa chỉ |
| **ProductService** | `8082` | `http://localhost:8082/swagger-ui.html` | Quản lý danh mục, sản phẩm, phân loại, đánh giá |
| **OrderService** | `8083` | `http://localhost:8083/swagger-ui.html` | Quản lý giỏ hàng, đơn hàng, đồng bộ kho liên dịch vụ |
| **VoucherService** | `8084` | `http://localhost:8084/swagger-ui.html` | Quản lý và áp dụng mã giảm giá |
| **SQL Server** | `1433` | `localhost:1433` (sa / StrongPassword@123) | Cơ sở dữ liệu quan hệ cho các microservices |
| **Zipkin** | `9411` | `http://localhost:9411` | Distributed Tracing Dashboard (Micrometer / Brave) |
| **Prometheus** | `9090` | `http://localhost:9090` | Thu thập metrics từ Actuator Prometheus endpoint |
| **Grafana** | `3000` | `http://localhost:3000` (admin / admin) | Trực quan hóa Metrics Dashboard (pre-loaded) |
| **Elasticsearch** | `9200` | `http://localhost:9200` | Lưu trữ và lập chỉ mục Logs tập trung |
| **Logstash** | `5000` | `tcp://localhost:5000` | Tiếp nhận logs dạng JSON từ các microservices |
| **Kibana** | `5601` | `http://localhost:5601` | Giao diện tìm kiếm, phân tích và lọc Logs tập trung |
| **RabbitMQ** | `5672` / `15672` | `http://localhost:15672` (guest / guest) | Message Broker & Quản trị hàng đợi AMQP |

---

## 🐇 Giao tiếp bất đồng bộ qua Message Broker (RabbitMQ)

- **Kiến trúc:** Event-Driven Architecture giữa `OrderService` (Producer) và `ProductService` (Consumer).
- **Exchange:** `stock.exchange` (Topic Exchange)
- **Queue:** `stock.sync.queue`
- **Routing Key:** `stock.sync.routingKey`
- **Luồng nghiệp vụ:**
  1. Khi người dùng **tạo đơn hàng** hoặc **hủy đơn hàng** ở `OrderService`, hệ thống lưu trạng thái đơn hàng và phát một sự kiện `StockSyncEvent` lên RabbitMQ (JSON serialization).
  2. `OrderService` phản hồi kết quả ngay lập tức cho người dùng mà không cần chờ gọi HTTP.
  3. `ProductService` lắng nghe sự kiện qua `@RabbitListener(queues = "stock.sync.queue")`, tự động bốc tin nhắn ra để cập nhật tồn kho (trừ kho khi tạo đơn, hoàn kho khi hủy đơn).
  4. **Độ tin cậy (Fault Tolerance):** Nếu `ProductService` đang bận hoặc tắt, tin nhắn vẫn được lưu an toàn trong hàng đợi. Ngoài ra có cơ chế **tự động fallback sang REST HTTP** nếu RabbitMQ tạm thời chưa kết nối.
- **Dashboard quản trị RabbitMQ:** Truy cập [http://localhost:15672](http://localhost:15672) (User: `guest` / Pass: `guest`) để xem realtime biểu đồ Message Queued, Consumers, Throughput.

---

## 📈 Giám sát, Theo vết & Ghi log tập trung (Monitoring, Tracing & Logging)

### 1. Distributed Tracing với Zipkin (`http://localhost:9411`)
- Mọi microservice đều được tích hợp **Micrometer Tracing** (Brave) và **Zipkin Reporter**.
- Khi một request đi qua `ApiGateway` và gọi sang các service backend (ví dụ: `ApiGateway` -> `OrderService` -> `ProductService`), toàn bộ chuỗi gọi (call tree), thời gian phản hồi (latency), và lỗi (nếu có) sẽ hiển thị chi tiết trên giao diện Zipkin cùng một `traceId`.

### 2. Giám sát hệ thống với Prometheus & Grafana (`http://localhost:3000`)
- **Prometheus** tự động scrape endpoint `/actuator/prometheus` của toàn bộ 7 microservices định kỳ mỗi 15 giây.
- **Grafana** đã được cấu hình tự động kết nối Datasource Prometheus và tự động nạp sẵn dashboard:
  - **Dashboard:** *Sports Store Microservices Overview*
  - **Các thông số theo dõi realtime:** CPU Process/System, JVM Heap Memory Used, Tần suất request HTTP (req/s), Độ trễ tối đa (Max Latency), Số lượng Threads hoạt động, Số lượng kết nối Database HikariCP (Active / Idle).

### 3. Centralized Logging với ELK Stack (`http://localhost:5601`)
- **Logback Socket TCP:** Mỗi microservice sử dụng `logstash-logback-encoder` để tự động đẩy logs dạng structured JSON qua cổng TCP 5000 về **Logstash**.
- **MDC Tracing Injection:** Mỗi dòng log đều được gắn kèm trường `service`, `traceId` và `spanId`.
- **Kibana Web UI:** Mở [http://localhost:5601](http://localhost:5601), tạo Index Pattern `sports-store-logs-*` để tìm kiếm logs theo thời gian thực, lọc theo tên `service`, hoặc tra cứu mọi logs phát sinh từ một `traceId` cụ thể xuyên suốt hệ thống.

---

## 🔑 Dữ liệu mẫu khởi tạo sẵn (Seed Data)

* **Tài khoản người dùng test:**
  - `a@gmail.com` / Mật khẩu: `123456` (Nguyễn Văn A - Nam)
  - `b@gmail.com` / Mật khẩu: `123456` (Nguyễn Văn B - Nam)
* **Voucher mẫu:**
  - `FREESHIP`: Miễn phí ship 30.000 ₫ cho đơn từ 500.000 ₫
  - `SPORT20`: Giảm 20% tối đa 150.000 ₫ cho đơn từ 1.000.000 ₫
  - `WELCOME50`: Giảm 50.000 ₫ cho đơn từ 300.000 ₫
* **Danh mục và sản phẩm mẫu:** Tự động seed bởi `DataSeeder` khi `product-service` khởi động.

---

## 🛑 Dừng hệ thống

```bash
docker compose down
```

Xóa luôn volume và container cũ nếu muốn khởi tạo lại từ đầu:

```bash
docker compose down -v
```
