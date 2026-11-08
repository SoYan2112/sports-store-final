package fu.ce190435.productservice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SelectVariantResponse {
    private String variantId;
    private String productId;
    private String productName;
    private String selectedSize;
    private Long selectedColorCode;
    private String selectedColorName;
    private Double price;
    private Integer stock;
    private boolean inStock;
    private List<String> availableSizes;
    private List<Long> availableColors;
}

