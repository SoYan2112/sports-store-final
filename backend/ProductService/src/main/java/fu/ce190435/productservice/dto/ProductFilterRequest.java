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
@Schema(description = "Yêu cầu lọc sản phẩm theo các tiêu chí (UC-17)")
public class ProductFilterRequest {

    @Schema(description = "Mã danh mục (VD: cat_shoes, cat_tops, cat_bottoms, cat_accessories)", example = "cat_shoes")
    private String categoryId;

    @Schema(description = "Thương hiệu sản phẩm (VD: Nike, Adidas, Puma, Reebok)", example = "Nike")
    private String brand;

    @Schema(description = "Mức giá tối thiểu (VNĐ)", example = "1000000")
    private Double minPrice;

    @Schema(description = "Mức giá tối đa (VNĐ)", example = "3000000")
    private Double maxPrice;

    @Schema(description = "Kích cỡ cần lọc (VD: 39, 40, 41, 42, 43)", example = "41")
    private String size;

    @Schema(description = "Mã màu dạng số (VD: 4279900698 = Đen, 4294967295 = Trắng, 4294929152 = Cam)", example = "4279900698")
    private Long colorCode;

    @Schema(description = "Điểm đánh giá tối thiểu (1.0 - 5.0)", example = "4.5")
    private Double minRating;

    @Schema(description = "Chỉ lấy sản phẩm còn hàng trong kho", example = "true")
    private Boolean inStockOnly;

    @Schema(description = "Chỉ lấy sản phẩm đang có chương trình giảm giá", example = "false")
    private Boolean hasDiscountOnly;

    @Schema(description = "Tiêu chí sắp xếp: price_asc, price_desc, rating_desc, popular, newest", example = "price_asc")
    private String sortBy;

    @Schema(description = "Số trang (bắt đầu từ 1)", example = "1")
    private Integer page;

    @Schema(description = "Số lượng sản phẩm mỗi trang", example = "10")
    private Integer pageSize;
}
