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
@Schema(description = "Thông tin chi tiết một lượt đánh giá sản phẩm (UC-23, UC-24)")
public class ProductRatingDTO {

    @Schema(description = "Mã định danh đánh giá", example = "rev_p1_01")
    private String id;

    @Schema(description = "Mã sản phẩm", example = "p1")
    private String productId;

    @Schema(description = "Mã người dùng", example = "user_01")
    private String userId;

    @Schema(description = "Tên người dùng đánh giá", example = "Hoàng Nhật")
    private String userName;

    @Schema(description = "Link ảnh đại diện", example = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100")
    private String userAvatar;

    @Schema(description = "Số sao đánh giá (1 - 5)", example = "5")
    private Integer rating;

    @Schema(description = "Nội dung nhận xét", example = "Giày rất êm, ôm chân cực tốt, đệm Joyride trợ lực chạy bộ đỉnh cao!")
    private String comment;

    @Schema(description = "Kích cỡ đã mua", example = "41")
    private String sizeBought;

    @Schema(description = "Màu sắc đã mua", example = "Đen thể thao")
    private String colorBought;

    @Schema(description = "Danh sách ảnh chụp thực tế từ khách hàng")
    private List<String> images;

    @Schema(description = "Thời gian tạo đánh giá (epoch milliseconds)", example = "1731067200000")
    private Long createdAt;
}
