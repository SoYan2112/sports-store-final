package fu.ce191491.orderservice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OrderCreateRequest {
    private String id;
    private String userId;
    private List<OrderItemRequest> items;
    private ShippingAddressRequest shippingAddress;
    private String paymentMethod;
    private String shippingMethod;
    private Double subtotal;
    private Double shippingFee;
    private Double discountAmount;
    private Double totalAmount;
    private String note;
    private String status;
    private String createdAt;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class OrderItemRequest {
        private String productId;
        private String name;
        private String brand;
        private Double price;
        private String imageUrl;
        private String selectedSize;
        private Integer selectedColor;
        private Integer quantity;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ShippingAddressRequest {
        private String id;
        private String recipientName;
        private String phoneNumber;
        private String province;
        private String district;
        private String ward;
        private String streetAddress;
        private String label;
        private Boolean isDefault;
    }
}
