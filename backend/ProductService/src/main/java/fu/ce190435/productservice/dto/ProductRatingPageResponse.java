package fu.ce190435.productservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Kết quả xem đánh giá sản phẩm có phân trang (UC-23)")
public class ProductRatingPageResponse {

    @Schema(description = "Mã sản phẩm", example = "p1")
    private String productId;

    @Schema(description = "Tên sản phẩm", example = "Nike unveil joyride")
    private String productName;

    @Schema(description = "Thống kê tổng quan số sao")
    private RatingSummaryDTO summary;

    @Schema(description = "Bộ lọc số sao đang áp dụng (null nếu xem tất cả)", example = "5")
    private Integer filteredStar;

    @Schema(description = "Trang hiện tại (bắt đầu từ 1)", example = "1")
    private int page;

    @Schema(description = "Số lượng đánh giá mỗi trang", example = "10")
    private int size;

    @Schema(description = "Tổng số trang", example = "1")
    private int totalPages;

    @Schema(description = "Tổng số đánh giá tìm thấy", example = "128")
    private int totalElements;

    @Schema(description = "Danh sách đánh giá chi tiết")
    private List<ProductRatingDTO> ratings;
}
