package fu.ce191491.orderservice.service.impl;

import fu.ce191491.orderservice.common.ApiException;
import fu.ce191491.orderservice.dto.OrderCreateRequest;
import fu.ce191491.orderservice.dto.OrderCreateResponse;
import fu.ce191491.orderservice.dto.OrderDetailResponse;
import fu.ce191491.orderservice.entity.Order;
import fu.ce191491.orderservice.entity.OrderItem;
import fu.ce191491.orderservice.entity.OrderStatus;
import fu.ce191491.orderservice.repository.OrderRepository;
import fu.ce191491.orderservice.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

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

    @Override
    @Transactional(readOnly = true)
    public List<OrderDetailResponse> getOrderHistory(String userId, String status) {
        if (userId == null || userId.isBlank()) {
            throw ApiException.badRequest("Mã khách hàng (userId) không được để trống");
        }

        List<Order> orders;
        OrderStatus orderStatus = OrderStatus.fromString(status);

        if (orderStatus != null) {
            // Lọc theo trạng thái cụ thể (PENDING, SHIPPING, DELIVERED, CANCELLED)
            orders = orderRepository.findByUserIdAndStatusOrderByCreatedAtDesc(userId.trim(), orderStatus);
        } else {
            // Lấy tất cả đơn hàng của user, sắp xếp mới nhất lên đầu
            orders = orderRepository.findByUserIdOrderByCreatedAtDesc(userId.trim());
        }

        return orders.stream()
                .map(this::mapToDetailResponse)
                .toList();
    }

    @Override
    @Transactional
    public OrderCreateResponse createOrder(OrderCreateRequest request) {
        if (request == null) {
            throw ApiException.badRequest("Dữ liệu đơn hàng không được để trống");
        }
        String userId = request.getUserId() == null || request.getUserId().isBlank()
                ? "guest"
                : request.getUserId().trim();
        if (request.getItems() == null || request.getItems().isEmpty()) {
            throw ApiException.badRequest("items không được để trống");
        }
        if (request.getShippingAddress() == null) {
            throw ApiException.badRequest("shippingAddress không được để trống");
        }
        if (request.getShippingAddress().getRecipientName() == null || request.getShippingAddress().getRecipientName().isBlank()) {
            throw ApiException.badRequest("recipientName không được để trống");
        }
        if (request.getShippingAddress().getPhoneNumber() == null || request.getShippingAddress().getPhoneNumber().isBlank()) {
            throw ApiException.badRequest("phoneNumber không được để trống");
        }

        BigDecimal subtotal = BigDecimal.valueOf(request.getSubtotal() == null ? 0.0 : request.getSubtotal());
        BigDecimal shippingFee = BigDecimal.valueOf(request.getShippingFee() == null ? 0.0 : request.getShippingFee());
        BigDecimal discountAmount = BigDecimal.valueOf(request.getDiscountAmount() == null ? 0.0 : request.getDiscountAmount());
        BigDecimal totalAmount = request.getTotalAmount() == null
                ? subtotal.add(shippingFee).subtract(discountAmount)
                : BigDecimal.valueOf(request.getTotalAmount());

        String orderId = request.getId() == null || request.getId().isBlank()
                ? "SS-" + Instant.now().toEpochMilli()
                : request.getId().trim();

        OrderStatus status = OrderStatus.fromString(request.getStatus());
        if (status == null) {
            status = OrderStatus.PENDING;
        }

        Order order = Order.builder()
                .id(orderId)
                .userId(userId)
                .recipientName(request.getShippingAddress().getRecipientName())
                .phoneNumber(request.getShippingAddress().getPhoneNumber())
                .province(request.getShippingAddress().getProvince())
                .district(request.getShippingAddress().getDistrict())
                .ward(request.getShippingAddress().getWard())
                .streetAddress(request.getShippingAddress().getStreetAddress())
                .paymentMethod(request.getPaymentMethod() == null ? "COD" : request.getPaymentMethod())
                .paymentStatus("UNPAID")
                .shippingMethod(request.getShippingMethod() == null ? "STANDARD" : request.getShippingMethod())
                .subtotal(subtotal)
                .shippingFee(shippingFee)
                .discountAmount(discountAmount)
                .totalAmount(totalAmount)
                .status(status)
                .note(request.getNote())
                .createdAt(System.currentTimeMillis())
                .updatedAt(System.currentTimeMillis())
                .build();

        List<OrderItem> orderItems = request.getItems().stream()
                .map(item -> {
                    BigDecimal price = BigDecimal.valueOf(item.getPrice() == null ? 0.0 : item.getPrice());
                    int quantity = item.getQuantity() == null ? 1 : Math.max(1, item.getQuantity());

                    return OrderItem.builder()
                            .order(order)
                            .productId(item.getProductId())
                            .productName(item.getName())
                            .brand(item.getBrand())
                            .imageUrl(item.getImageUrl())
                            .selectedSize(item.getSelectedSize())
                            .selectedColor(item.getSelectedColor() == null ? 0xFF1A1A1AL : item.getSelectedColor().longValue())
                            .price(price)
                            .quantity(quantity)
                            .itemTotal(price.multiply(BigDecimal.valueOf(quantity)))
                            .build();
                })
                .toList();

        order.getItems().addAll(orderItems);

        Order savedOrder = orderRepository.save(order);

        return OrderCreateResponse.builder()
                .id(savedOrder.getId())
                .userId(savedOrder.getUserId())
                .items(savedOrder.getItems().stream().map(item -> OrderCreateResponse.OrderItemResponse.builder()
                        .productId(item.getProductId())
                        .name(item.getProductName())
                        .brand(item.getBrand())
                        .price(item.getPrice().doubleValue())
                        .imageUrl(item.getImageUrl())
                        .selectedSize(item.getSelectedSize())
                        .selectedColor(item.getSelectedColor() == null ? 0xFF1A1A1A : item.getSelectedColor().intValue())
                        .quantity(item.getQuantity())
                        .build()).toList())
                .shippingAddress(OrderCreateResponse.ShippingAddressResponse.builder()
                        .id(request.getShippingAddress().getId())
                        .recipientName(savedOrder.getRecipientName())
                        .phoneNumber(savedOrder.getPhoneNumber())
                        .province(savedOrder.getProvince())
                        .district(savedOrder.getDistrict())
                        .ward(savedOrder.getWard())
                        .streetAddress(savedOrder.getStreetAddress())
                        .label(request.getShippingAddress().getLabel())
                        .isDefault(request.getShippingAddress().getIsDefault())
                        .build())
                .paymentMethod(savedOrder.getPaymentMethod())
                .shippingMethod(savedOrder.getShippingMethod())
                .subtotal(savedOrder.getSubtotal().doubleValue())
                .shippingFee(savedOrder.getShippingFee().doubleValue())
                .discountAmount(savedOrder.getDiscountAmount().doubleValue())
                .totalAmount(savedOrder.getTotalAmount().doubleValue())
                .note(savedOrder.getNote())
                .status(savedOrder.getStatus().getDescription())
                .createdAt(Instant.ofEpochMilli(savedOrder.getCreatedAt()).toString())
                .build();
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
