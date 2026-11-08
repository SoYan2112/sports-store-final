package fu.ce190435.productservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Thông tin bộ lọc đã được áp dụng trong kết quả trả về")
public class FilterAppliedDTO {

    @Schema(description = "Mã danh mục đã lọc", example = "cat_shoes")
    private String categoryId;

    @Schema(description = "Thương hiệu đã lọc", example = "Nike")
    private String brand;

    @Schema(description = "Giá tối thiểu đã áp dụng", example = "1000000.0")
    private Double minPrice;

    @Schema(description = "Giá tối đa đã áp dụng", example = "3000000.0")
    private Double maxPrice;

    @Schema(description = "Kích cỡ đã lọc", example = "41")
    private String size;

    @Schema(description = "Mã màu đã lọc", example = "4279900698")
    private Long colorCode;

    @Schema(description = "Điểm đánh giá tối thiểu đã lọc", example = "4.5")
    private Double minRating;

    @Schema(description = "Chỉ lọc hàng còn trong kho", example = "true")
    private Boolean inStockOnly;

    @Schema(description = "Chỉ lọc hàng có giảm giá", example = "false")
    private Boolean hasDiscountOnly;

    @Schema(description = "Tiêu chí sắp xếp kết quả", example = "price_asc")
    private String sortBy;
}
