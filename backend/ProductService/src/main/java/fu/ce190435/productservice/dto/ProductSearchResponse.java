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
@Schema(description = "Kết quả tìm kiếm sản phẩm theo từ khóa (UC-09)")
public class ProductSearchResponse {

    @Schema(description = "Từ khóa tìm kiếm đã sử dụng", example = "Nike")
    private String keyword;

    @Schema(description = "Tổng số sản phẩm tìm thấy phù hợp", example = "3")
    private int totalElements;

    @Schema(description = "Trạng thái có tìm thấy sản phẩm phù hợp hay không", example = "true")
    private boolean hasResults;

    @Schema(description = "Trang hiện tại (bắt đầu từ 1)", example = "1")
    private int page;

    @Schema(description = "Số lượng phần tử mỗi trang", example = "10")
    private int size;

    @Schema(description = "Tổng số trang", example = "1")
    private int totalPages;

    @Schema(description = "Tiêu chí sắp xếp áp dụng (relevance, price_asc, price_desc, rating_desc, newest)", example = "relevance")
    private String sortBy;

    @Schema(description = "Danh sách sản phẩm tìm được")
    private List<ProductDTO> products;
}
