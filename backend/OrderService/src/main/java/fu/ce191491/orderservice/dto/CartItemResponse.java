package fu.ce191491.orderservice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CartItemResponse {
    private String id;
    private String productId;
    private String name;
    private String brand;
    private Double price;
    private String imageUrl;
    private String selectedSize;
    private Integer selectedColor;
    private Integer quantity;
    private Integer stock;
}
