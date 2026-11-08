package fu.ce190435.productservice.controller;

import fu.ce190435.productservice.common.ApiResponse;
import fu.ce190435.productservice.dto.ProductDTO;
import fu.ce190435.productservice.dto.ProductDetailDTO;
import fu.ce190435.productservice.dto.ProductVariantDTO;
import fu.ce190435.productservice.dto.SelectVariantResponse;
import fu.ce190435.productservice.service.ProductService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/products")
@RequiredArgsConstructor
@Tag(name = "Product API", description = "Các API xem danh sách sản phẩm, xem chi tiết sản phẩm và chọn biến thể Size/Màu")
public class ProductController {

    private final ProductService productService;

    @GetMapping
    @Operation(
            summary = "Xem danh sách sản phẩm",
            description = "Lấy danh sách sản phẩm có phân trang (page, size), hỗ trợ lọc theo mã danh mục (categoryId) hoặc từ khóa (keyword)."
    )
    public ResponseEntity<ApiResponse<List<ProductDTO>>> getProducts(
            @Parameter(description = "Số trang (bắt đầu từ 1)", example = "1")
            @RequestParam(defaultValue = "1") int page,
            @Parameter(description = "Số lượng sản phẩm mỗi trang", example = "6")
            @RequestParam(defaultValue = "10") int size,
            @Parameter(description = "Mã danh mục lọc (VD: cat_shoes, cat_tops, cat_bottoms, cat_accessories)", example = "")
            @RequestParam(required = false) String categoryId,
            @Parameter(description = "Từ khóa tìm kiếm theo tên hoặc thương hiệu (VD: Nike, Adidas)", example = "")
            @RequestParam(required = false) String keyword) {
        List<ProductDTO> products = productService.getProducts(page, size, categoryId, keyword);
        return ResponseEntity.ok(ApiResponse.success("Lấy danh sách sản phẩm thành công", products));
    }

    @GetMapping("/{id}")
    @Operation(
            summary = "Xem chi tiết sản phẩm",
            description = "Trả về thông tin chi tiết của một sản phẩm theo ID (bao gồm mô tả, bộ ảnh gallery, phần trăm giảm giá, danh sách size và màu sắc)."
    )
    public ResponseEntity<ApiResponse<ProductDetailDTO>> getProductById(
            @Parameter(description = "Mã sản phẩm (VD: p1, p2, p3, p4, p_top_1)", example = "p1")
            @PathVariable String id) {
        ProductDetailDTO detail = productService.getProductById(id);
        return ResponseEntity.ok(ApiResponse.success("Lấy chi tiết sản phẩm thành công", detail));
    }

    @GetMapping("/{id}/variants")
    @Operation(
            summary = "Lấy danh sách tất cả biến thể Size và Màu của sản phẩm",
            description = "Trả về toàn bộ các tổ hợp Size (38-43) và Màu sắc kèm số lượng tồn kho (stock) của sản phẩm."
    )
    public ResponseEntity<ApiResponse<List<ProductVariantDTO>>> getProductVariants(
            @Parameter(description = "Mã sản phẩm (VD: p1, p2)", example = "p1")
            @PathVariable String id) {
        List<ProductVariantDTO> variants = productService.getProductVariants(id);
        return ResponseEntity.ok(ApiResponse.success("Lấy danh sách biến thể sản phẩm thành công", variants));
    }

    @GetMapping("/{id}/variants/select")
    @Operation(
            summary = "Chọn biến thể sản phẩm theo Size và Màu",
            description = "Kiểm tra tồn kho (stock), trạng thái còn hàng (inStock) và giá bán khi khách hàng chọn một Size và Màu sắc cụ thể."
    )
    public ResponseEntity<ApiResponse<SelectVariantResponse>> selectProductVariant(
            @Parameter(description = "Mã sản phẩm (VD: p1, p2)", example = "p1")
            @PathVariable String id,
            @Parameter(description = "Kích cỡ giày/áo (VD: 38, 39, 40, 41, 42, 43)", example = "41")
            @RequestParam String size,
            @Parameter(description = "Mã màu dạng số (VD: 4279900698 = Đen, 4294967295 = Trắng, 4294929152 = Cam)", example = "4279900698")
            @RequestParam(required = false) Long colorCode) {
        SelectVariantResponse result = productService.selectProductVariant(id, size, colorCode);
        return ResponseEntity.ok(ApiResponse.success("Chọn biến thể sản phẩm thành công", result));
    }
}
