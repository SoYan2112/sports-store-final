package fu.ce190435.productservice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductDTO {
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
    private String category;
    private String categoryId;
    private Integer stock;
}

