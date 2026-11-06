package fu.ce191491.orderservice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderDetailResponse {
    private String id;
    private String userId;
    private String status;
    private String statusDescription;
    private String cancelReason;
    private String note;
    private Long createdAt;
    private Long updatedAt;

    private ShippingAddressDTO shippingAddress;
    private PaymentInfoDTO payment;
    private PricingSummaryDTO pricing;
    private List<OrderItemDTO> items;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ShippingAddressDTO {
        private String recipientName;
        private String phoneNumber;
        private String province;
        private String district;
        private String ward;
        private String streetAddress;
        private String fullAddress;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PaymentInfoDTO {
        private String paymentMethod;
        private String paymentStatus;
        private String shippingMethod;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PricingSummaryDTO {
        private BigDecimal subtotal;
        private BigDecimal shippingFee;
        private BigDecimal discountAmount;
        private BigDecimal totalAmount;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class OrderItemDTO {
        private Long id;
        private String productId;
        private String productName;
        private String brand;
        private String imageUrl;
        private String selectedSize;
        private Long selectedColor;
        private BigDecimal price;
        private Integer quantity;
        private BigDecimal itemTotal;
    }
}

