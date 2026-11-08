package fu.ce190435.productservice.controller;

import fu.ce190435.productservice.common.ApiResponse;
import fu.ce190435.productservice.dto.CategoryDTO;
import fu.ce190435.productservice.service.CategoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/categories")
@RequiredArgsConstructor
@Tag(name = "Category API", description = "Các API xem danh sách danh mục ngành hàng thể thao và chi tiết danh mục")
public class CategoryController {

    private final CategoryService categoryService;

    @GetMapping
    @Operation(
            summary = "Xem danh sách danh mục sản phẩm",
            description = "Trả về toàn bộ các danh mục ngành hàng thể thao (Giày, Áo, Quần, Phụ kiện, Dụng cụ, Đồ bảo hộ) kèm số lượng sản phẩm trong từng danh mục."
    )
    public ResponseEntity<ApiResponse<List<CategoryDTO>>> getAllCategories() {
        List<CategoryDTO> categories = categoryService.getAllCategories();
        return ResponseEntity.ok(ApiResponse.success("Lấy danh sách danh mục sản phẩm thành công", categories));
    }

    @GetMapping("/{id}")
    @Operation(
            summary = "Xem chi tiết một danh mục theo ID",
            description = "Lấy thông tin chi tiết và số lượng sản phẩm của một danh mục cụ thể."
    )
    public ResponseEntity<ApiResponse<CategoryDTO>> getCategoryById(
            @Parameter(description = "Mã danh mục (VD: cat_shoes, cat_tops, cat_bottoms, cat_accessories, cat_gear, cat_protection)", example = "cat_shoes")
            @PathVariable String id) {
        CategoryDTO category = categoryService.getCategoryById(id);
        return ResponseEntity.ok(ApiResponse.success("Lấy thông tin danh mục thành công", category));
    }
}
