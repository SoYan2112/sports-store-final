package fu.ce190435.productservice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductVariantDTO {
    private String id;
    private String productId;
    private String size;
    private Long colorCode;
    private String colorName;
    private Integer stock;
    private Double price;
    private boolean inStock;
}

