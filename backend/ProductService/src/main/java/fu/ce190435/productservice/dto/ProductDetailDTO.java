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
public class ProductDetailDTO {
    private String id;
    private String name;
    private String brand;
    private Double price;
    private Double originalPrice;
    private String imageUrl;
    private String badge;
    private Double rating;
    private Integer reviewCount;
    private String description;
    private List<String> images;
    private String category;
    private String categoryId;
    private Integer stock;
    private List<String> sizes;
    private List<Long> colors;
    private boolean hasDiscount;
    private Integer discountPercentage;
}

