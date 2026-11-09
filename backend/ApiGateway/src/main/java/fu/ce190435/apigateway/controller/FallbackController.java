package fu.ce190435.apigateway.controller;

import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Map;

@RestController
@RequestMapping("/fallback")
public class FallbackController {

    @GetMapping("/identity")
    @CircuitBreaker(name = "identityService", fallbackMethod = "defaultFallback")
    public ResponseEntity<Map<String, Object>> identityFallback() {
        return buildFallbackResponse("Dịch vụ Tài khoản (IdentityService) đang bảo trì hoặc quá tải. Vui lòng thử lại sau.");
    }

    @GetMapping("/product")
    @CircuitBreaker(name = "productService", fallbackMethod = "defaultFallback")
    public ResponseEntity<Map<String, Object>> productFallback() {
        return buildFallbackResponse("Dịch vụ Sản phẩm (ProductService) đang bảo trì hoặc quá tải. Vui lòng thử lại sau.");
    }

    @GetMapping("/order")
    @CircuitBreaker(name = "orderService", fallbackMethod = "defaultFallback")
    public ResponseEntity<Map<String, Object>> orderFallback() {
        return buildFallbackResponse("Dịch vụ Đơn hàng (OrderService) đang bảo trì hoặc quá tải. Vui lòng thử lại sau.");
    }

    @GetMapping("/voucher")
    @CircuitBreaker(name = "voucherService", fallbackMethod = "defaultFallback")
    public ResponseEntity<Map<String, Object>> voucherFallback() {
        return buildFallbackResponse("Dịch vụ Khuyến mãi (VoucherService) đang bảo trì hoặc quá tải. Vui lòng thử lại sau.");
    }

    public ResponseEntity<Map<String, Object>> defaultFallback(Throwable throwable) {
        return buildFallbackResponse("Hệ thống đang bận: " + throwable.getMessage());
    }

    private ResponseEntity<Map<String, Object>> buildFallbackResponse(String message) {
        Map<String, Object> body = Map.of(
                "status", 0,
                "message", message,
                "timestamp", Instant.now().truncatedTo(ChronoUnit.SECONDS).toString()
        );
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(body);
    }
}
