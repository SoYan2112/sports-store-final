package fu.ce190435.productservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Yêu cầu thêm đánh giá sản phẩm (UC-24)")
public class AddRatingRequest {

    @NotBlank(message = "Mã người dùng không được để trống")
    @Schema(description = "Mã định danh người dùng", example = "user_01", requiredMode = Schema.RequiredMode.REQUIRED)
    private String userId;

    @NotBlank(message = "Tên người dùng không được để trống")
    @Schema(description = "Tên hiển thị của người đánh giá", example = "Hoàng Nhật", requiredMode = Schema.RequiredMode.REQUIRED)
    private String userName;

    @Schema(description = "Link ảnh đại diện", example = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100")
    private String userAvatar;

    @NotNull(message = "Số sao đánh giá không được để trống")
    @Min(value = 1, message = "Số sao tối thiểu là 1")
    @Max(value = 5, message = "Số sao tối đa là 5")
    @Schema(description = "Số sao đánh giá từ 1 đến 5", example = "5", requiredMode = Schema.RequiredMode.REQUIRED)
    private Integer rating;

    @Schema(description = "Nội dung nhận xét về sản phẩm", example = "Giày rất êm, ôm chân cực tốt, đệm Joyride trợ lực chạy bộ đỉnh cao!")
    private String comment;

    @Schema(description = "Kích cỡ đã mua", example = "41")
    private String sizeBought;

    @Schema(description = "Màu sắc đã mua", example = "Đen thể thao")
    private String colorBought;

    @Schema(description = "Danh sách link ảnh chụp thực tế sản phẩm")
    private List<String> images;
}
