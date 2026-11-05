package fu.ce191491.orderservice.service;

import fu.ce191491.orderservice.dto.OrderDetailResponse;

public interface OrderService {
    OrderDetailResponse getOrderDetail(String orderId, String userId);

    OrderDetailResponse cancelOrder(String orderId, String userId, String reason);
}
