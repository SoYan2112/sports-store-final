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
@Schema(description = "Thông tin tóm tắt sản phẩm")
public class ProductDTO {

    @Schema(description = "Mã sản phẩm", example = "p1")
    private String id;

    @Schema(description = "Tên sản phẩm", example = "Nike unveil joyride")
    private String name;

    @Schema(description = "Thương hiệu", example = "Nike")
    private String brand;

    @Schema(description = "Giá bán hiện tại (VNĐ)", example = "1950000.0")
    private Double price;

    @Schema(description = "Giá gốc trước giảm giá (VNĐ)", example = "2450000.0")
    private Double originalPrice;

    @Schema(description = "Ảnh đại diện sản phẩm", example = "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&auto=format&fit=crop&q=80")
    private String imageUrl;

    @Schema(description = "Huy hiệu/Nhãn sản phẩm (Hot, New, Sale...)", example = "Hot")
    private String badge;

    @Schema(description = "Điểm đánh giá trung bình (1.0 - 5.0)", example = "4.9")
    private Double rating;

    @Schema(description = "Số lượng đánh giá nhận được", example = "128")
    private Integer reviewCount;

    @Schema(description = "Mô tả ngắn của sản phẩm", example = "Giày chạy bộ cao cấp với hạt đệm Joyride êm ái, trợ lực tối đa.")
    private String description;

    @Schema(description = "Tên danh mục", example = "Giày thể thao")
    private String category;

    @Schema(description = "Mã định danh danh mục", example = "cat_shoes")
    private String categoryId;

    @Schema(description = "Số lượng tồn kho", example = "15")
    private Integer stock;
}
