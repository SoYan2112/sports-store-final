package fu.ce191491.orderservice.service;

import fu.ce191491.orderservice.dto.OrderCreateRequest;
import fu.ce191491.orderservice.dto.OrderCreateResponse;
import fu.ce191491.orderservice.dto.OrderDetailResponse;

import java.util.List;

public interface OrderService {
    OrderDetailResponse getOrderDetail(String orderId, String userId);

    OrderDetailResponse cancelOrder(String orderId, String userId, String reason);

    List<OrderDetailResponse> getOrderHistory(String userId, String status);

    OrderCreateResponse createOrder(OrderCreateRequest request);
}
