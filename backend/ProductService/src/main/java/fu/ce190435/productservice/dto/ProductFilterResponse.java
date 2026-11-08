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
@Schema(description = "Kết quả lọc sản phẩm theo nhiều tiêu chí (UC-17)")
public class ProductFilterResponse {

    @Schema(description = "Tổng số sản phẩm phù hợp với bộ lọc", example = "5")
    private int totalElements;

    @Schema(description = "Trạng thái có tìm thấy sản phẩm phù hợp bộ lọc hay không", example = "true")
    private boolean hasResults;

    @Schema(description = "Trang hiện tại (bắt đầu từ 1)", example = "1")
    private int page;

    @Schema(description = "Số lượng sản phẩm mỗi trang", example = "10")
    private int size;

    @Schema(description = "Tổng số trang", example = "1")
    private int totalPages;

    @Schema(description = "Thông tin bộ lọc đã áp dụng")
    private FilterAppliedDTO appliedFilters;

    @Schema(description = "Danh sách sản phẩm phù hợp bộ lọc")
    private List<ProductDTO> products;
}
