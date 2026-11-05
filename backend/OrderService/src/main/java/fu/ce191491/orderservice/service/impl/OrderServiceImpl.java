package fu.ce191491.orderservice.service.impl;

import fu.ce191491.orderservice.common.ApiException;
import fu.ce191491.orderservice.dto.OrderDetailResponse;
import fu.ce191491.orderservice.entity.Order;
import fu.ce191491.orderservice.entity.OrderStatus;
import fu.ce191491.orderservice.repository.OrderRepository;
import fu.ce191491.orderservice.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;

    @Override
    @Transactional(readOnly = true)
    public OrderDetailResponse getOrderDetail(String orderId, String userId) {
        if (orderId == null || orderId.isBlank()) {
            throw ApiException.badRequest("Mã đơn hàng không được để trống");
        }
        if (userId == null || userId.isBlank()) {
            throw ApiException.badRequest("Mã khách hàng (userId) không được để trống");
        }

        // Truy vấn chính xác theo cả orderId VÀ userId (Bảo mật: User chỉ xem được đơn của chính mình)
        Order order = orderRepository.findWithItemsByIdAndUserId(orderId.trim(), userId.trim())
                .orElseThrow(() -> ApiException.notFound(
                        "Không tìm thấy đơn hàng #" + orderId + " thuộc về tài khoản '" + userId + "'"));

        // Chuyển đổi Entity sang DTO
        return mapToDetailResponse(order);
    }

    @Override
    @Transactional
    public OrderDetailResponse cancelOrder(String orderId, String userId, String reason) {
        if (orderId == null || orderId.isBlank()) {
            throw ApiException.badRequest("Mã đơn hàng không được để trống");
        }
        if (userId == null || userId.isBlank()) {
            throw ApiException.badRequest("Mã khách hàng (userId) không được để trống");
        }
        if (reason == null || reason.trim().isEmpty()) {
            throw ApiException.badRequest("Lý do hủy đơn không được để trống");
        }

        // 1. Tìm đơn hàng theo orderId VÀ userId
        Order order = orderRepository.findWithItemsByIdAndUserId(orderId.trim(), userId.trim())
                .orElseThrow(() -> ApiException.notFound(
                        "Không tìm thấy đơn hàng #" + orderId + " thuộc về tài khoản '" + userId + "'"));

        // 2. Kiểm tra điều kiện nghiệp vụ: Chỉ cho phép hủy khi ở trạng thái 'Chờ xác nhận' (PENDING)
        if (order.getStatus() == OrderStatus.CANCELLED) {
            throw ApiException.badRequest("Đơn hàng này đã được hủy trước đó.");
        }
        if (order.getStatus() == OrderStatus.SHIPPING) {
            throw ApiException.badRequest("Đơn hàng đang trong quá trình vận chuyển, không thể hủy.");
        }
        if (order.getStatus() == OrderStatus.DELIVERED) {
            throw ApiException.badRequest("Đơn hàng đã được giao hoàn tất, không thể hủy.");
        }
        if (order.getStatus() != OrderStatus.PENDING) {
            throw ApiException.badRequest("Chỉ có thể hủy đơn hàng khi đơn ở trạng thái 'Chờ xác nhận'.");
        }

        // 3. Tiến hành cập nhật trạng thái hủy và lý do
        order.setStatus(OrderStatus.CANCELLED);
        order.setCancelReason(reason.trim());
        order.setUpdatedAt(System.currentTimeMillis());

        Order updatedOrder = orderRepository.save(order);

        // 4. Trả về thông tin chi tiết đơn hàng sau khi cập nhật
        return mapToDetailResponse(updatedOrder);
    }

    private OrderDetailResponse mapToDetailResponse(Order order) {
        String fullAddress = String.format("%s, %s, %s, %s",
                order.getStreetAddress() != null ? order.getStreetAddress() : "",
                order.getWard() != null ? order.getWard() : "",
                order.getDistrict() != null ? order.getDistrict() : "",
                order.getProvince() != null ? order.getProvince() : "").replaceAll("^[ ,]+|[ ,]+$", "");

        return OrderDetailResponse.builder()
                .id(order.getId())
                .userId(order.getUserId())
                .status(order.getStatus() != null ? order.getStatus().name() : "PENDING")
                .statusDescription(order.getStatus() != null ? order.getStatus().getDescription() : "Chờ xác nhận")
                .cancelReason(order.getCancelReason())
                .note(order.getNote())
                .createdAt(order.getCreatedAt())
                .updatedAt(order.getUpdatedAt())
                .shippingAddress(OrderDetailResponse.ShippingAddressDTO.builder()
                        .recipientName(order.getRecipientName())
                        .phoneNumber(order.getPhoneNumber())
                        .province(order.getProvince())
                        .district(order.getDistrict())
                        .ward(order.getWard())
                        .streetAddress(order.getStreetAddress())
                        .fullAddress(fullAddress)
                        .build())
                .payment(OrderDetailResponse.PaymentInfoDTO.builder()
                        .paymentMethod(order.getPaymentMethod())
                        .paymentStatus(order.getPaymentStatus())
                        .shippingMethod(order.getShippingMethod())
                        .build())
                .pricing(OrderDetailResponse.PricingSummaryDTO.builder()
                        .subtotal(order.getSubtotal())
                        .shippingFee(order.getShippingFee())
                        .discountAmount(order.getDiscountAmount())
                        .totalAmount(order.getTotalAmount())
                        .build())
                .items(order.getItems().stream().map(item -> OrderDetailResponse.OrderItemDTO.builder()
                        .id(item.getId())
                        .productId(item.getProductId())
                        .productName(item.getProductName())
                        .brand(item.getBrand())
                        .imageUrl(item.getImageUrl())
                        .selectedSize(item.getSelectedSize())
                        .selectedColor(item.getSelectedColor())
                        .price(item.getPrice())
                        .quantity(item.getQuantity())
                        .itemTotal(item.getItemTotal())
                        .build()).toList())
                .build();
    }
}
