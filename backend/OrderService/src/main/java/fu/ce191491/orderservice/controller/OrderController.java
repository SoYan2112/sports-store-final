package fu.ce191491.orderservice.controller;

import fu.ce191491.orderservice.common.ApiResponse;
import fu.ce191491.orderservice.dto.CancelOrderRequest;
import fu.ce191491.orderservice.dto.OrderDetailResponse;
import fu.ce191491.orderservice.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
@Tag(name = "Order Controller", description = "APIs Quản lý Đơn hàng - CE191491")
public class OrderController {

    private final OrderService orderService;

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<OrderDetailResponse>> getOrderDetail(
            @Parameter(description = "Mã đơn hàng cần xem (ví dụ: ORD-001)", required = true)
            @PathVariable("id") String orderId,

            @Parameter(description = "Mã người dùng sở hữu đơn (ví dụ: user-ce191491)", required = true)
            @RequestParam("userId") String userId) {

        OrderDetailResponse detail = orderService.getOrderDetail(orderId, userId);
        return ResponseEntity.ok(ApiResponse.success("Lấy thông tin chi tiết đơn hàng thành công", detail));
    }

    @PostMapping("/{id}/cancel")
    public ResponseEntity<ApiResponse<OrderDetailResponse>> cancelOrder(
            @Parameter(description = "Mã đơn hàng cần hủy (ví dụ: ORD-001)", required = true)
            @PathVariable("id") String orderId,

            @Parameter(description = "Mã người dùng sở hữu đơn (ví dụ: user-ce191491)", required = true)
            @RequestParam("userId") String userId,

            @Valid @RequestBody CancelOrderRequest request) {

        OrderDetailResponse detail = orderService.cancelOrder(orderId, userId, request.getReason());
        return ResponseEntity.ok(ApiResponse.success("Hủy đơn hàng thành công", detail));
    }
}
