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
@Schema(description = "Thống kê tổng quan số sao đánh giá của sản phẩm")
public class RatingSummaryDTO {

    @Schema(description = "Điểm đánh giá trung bình (1.0 - 5.0)", example = "4.9")
    private Double averageRating;

    @Schema(description = "Tổng số lượt đánh giá", example = "128")
    private Integer totalReviews;

    @Schema(description = "Số lượng đánh giá 5 sao", example = "115")
    private Integer fiveStarCount;

    @Schema(description = "Số lượng đánh giá 4 sao", example = "10")
    private Integer fourStarCount;

    @Schema(description = "Số lượng đánh giá 3 sao", example = "2")
    private Integer threeStarCount;

    @Schema(description = "Số lượng đánh giá 2 sao", example = "1")
    private Integer twoStarCount;

    @Schema(description = "Số lượng đánh giá 1 sao", example = "0")
    private Integer oneStarCount;
}
