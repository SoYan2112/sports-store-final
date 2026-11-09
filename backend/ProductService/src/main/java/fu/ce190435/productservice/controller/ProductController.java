package fu.ce190435.productservice.controller;

import fu.ce190435.productservice.common.ApiResponse;
import fu.ce190435.productservice.dto.AddRatingRequest;
import fu.ce190435.productservice.dto.ProductDTO;
import fu.ce190435.productservice.dto.ProductDetailDTO;
import fu.ce190435.productservice.dto.ProductFilterRequest;
import fu.ce190435.productservice.dto.ProductFilterResponse;
import fu.ce190435.productservice.dto.ProductRatingDTO;
import fu.ce190435.productservice.dto.ProductRatingPageResponse;
import fu.ce190435.productservice.dto.ProductSearchResponse;
import fu.ce190435.productservice.dto.ProductVariantDTO;
import fu.ce190435.productservice.dto.SelectVariantResponse;
import fu.ce190435.productservice.service.ProductService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/products")
@RequiredArgsConstructor
@Tag(name = "Product API", description = "Các API xem danh sách, tìm kiếm, lọc sản phẩm, xem chi tiết, chọn biến thể Size/Màu và đánh giá sản phẩm")
public class ProductController {

    private final ProductService productService;

    @GetMapping
    @Operation(
            summary = "UC-04: Xem danh sách sản phẩm",
            description = "Lấy danh sách sản phẩm có phân trang (page, size), hỗ trợ lọc theo mã danh mục (categoryId) hoặc từ khóa (keyword)."
    )
    public ResponseEntity<ApiResponse<List<ProductDTO>>> getProducts(
            @Parameter(description = "Số trang (bắt đầu từ 1)", example = "1")
            @RequestParam(defaultValue = "1") int page,
            @Parameter(description = "Số lượng sản phẩm mỗi trang", example = "10")
            @RequestParam(defaultValue = "10") int size,
            @Parameter(description = "Mã danh mục lọc (VD: cat_shoes, cat_tops, cat_bottoms, cat_accessories)", example = "")
            @RequestParam(required = false) String categoryId,
            @Parameter(description = "Từ khóa tìm kiếm theo tên hoặc thương hiệu (VD: Nike, Adidas)", example = "")
            @RequestParam(required = false) String keyword) {
        List<ProductDTO> products = productService.getProducts(page, size, categoryId, keyword);
        return ResponseEntity.ok(ApiResponse.success("Lấy danh sách sản phẩm thành công", products));
    }

    @GetMapping("/search")
    @Operation(
            summary = "UC-09: Tìm kiếm sản phẩm theo từ khóa",
            description = "Tìm kiếm thông minh sản phẩm thể thao theo tên, thương hiệu (Nike, Adidas, Puma...), danh mục ngành hàng hoặc mô tả chi tiết. Hỗ trợ sắp xếp theo độ phù hợp (relevance), giá tăng dần (price_asc), giá giảm dần (price_desc), đánh giá sao cao nhất (rating_desc), hoặc hàng mới nhất (newest) kèm phân trang chi tiết."
    )
    @ApiResponses({
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "Tìm kiếm sản phẩm thành công"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "Tham số tìm kiếm không hợp lệ")
    })
    public ResponseEntity<ApiResponse<ProductSearchResponse>> searchProducts(
            @Parameter(description = "Từ khóa tìm kiếm (VD: Nike, Ultraboost, Joyride, Giày, Áo khoác...)", example = "Nike")
            @RequestParam(required = false, defaultValue = "") String keyword,
            @Parameter(description = "Số trang (bắt đầu từ 1)", example = "1")
            @RequestParam(defaultValue = "1") int page,
            @Parameter(description = "Số lượng sản phẩm mỗi trang", example = "10")
            @RequestParam(defaultValue = "10") int size,
            @Parameter(description = "Tiêu chí sắp xếp: relevance (độ liên quan), price_asc (giá tăng dần), price_desc (giá giảm dần), rating_desc (đánh giá sao cao nhất), newest (hàng mới nhất)", example = "relevance")
            @RequestParam(defaultValue = "relevance") String sortBy) {
        ProductSearchResponse response = productService.searchProducts(keyword, page, size, sortBy);

        String message;
        if (!response.isHasResults()) {
            if (keyword != null && !keyword.isBlank()) {
                message = "Không tìm thấy sản phẩm nào phù hợp với từ khóa '" + keyword.trim() + "'";
            } else {
                message = "Không tìm thấy sản phẩm nào";
            }
        } else {
            if (keyword != null && !keyword.isBlank()) {
                message = "Tìm thấy " + response.getTotalElements() + " sản phẩm phù hợp với từ khóa '" + keyword.trim() + "'";
            } else {
                message = "Lấy danh sách sản phẩm thành công";
            }
        }

        return ResponseEntity.ok(ApiResponse.success(message, response));
    }

    @GetMapping("/filter")
    @Operation(
            summary = "UC-17: Lọc sản phẩm theo nhiều tiêu chí",
            description = "Bộ lọc sản phẩm đa năng dành cho ngành hàng thể thao: lọc theo danh mục, nhãn hàng (Nike, Adidas, Puma...), khoảng giá (minPrice, maxPrice), kích cỡ (38-43), mã màu sắc, điểm đánh giá tối thiểu, trạng thái còn hàng và chỉ lấy hàng giảm giá. Hỗ trợ sắp xếp kết quả theo giá tăng/giảm, đánh giá sao cao nhất, độ phổ biến, hoặc hàng mới nhất."
    )
    @ApiResponses({
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "Lọc sản phẩm thành công"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "Tham số lọc không hợp lệ (ví dụ: minPrice > maxPrice)")
    })
    public ResponseEntity<ApiResponse<ProductFilterResponse>> filterProducts(
            @Parameter(description = "Mã danh mục (VD: cat_shoes, cat_tops, cat_bottoms, cat_accessories)", example = "cat_shoes")
            @RequestParam(required = false) String categoryId,
            @Parameter(description = "Thương hiệu (VD: Nike, Adidas, Puma, Reebok)", example = "Nike")
            @RequestParam(required = false) String brand,
            @Parameter(description = "Mức giá tối thiểu (VNĐ)", example = "1000000")
            @RequestParam(required = false) Double minPrice,
            @Parameter(description = "Mức giá tối đa (VNĐ)", example = "3000000")
            @RequestParam(required = false) Double maxPrice,
            @Parameter(description = "Kích cỡ giày/áo (VD: 39, 40, 41, 42, 43)", example = "41")
            @RequestParam(required = false) String size,
            @Parameter(description = "Mã màu dạng số (VD: 4279900698 = Đen, 4294967295 = Trắng, 4294929152 = Cam)", example = "")
            @RequestParam(required = false) Long colorCode,
            @Parameter(description = "Điểm đánh giá tối thiểu (1.0 - 5.0)", example = "4.5")
            @RequestParam(required = false) Double minRating,
            @Parameter(description = "Chỉ lấy sản phẩm còn hàng trong kho", example = "false")
            @RequestParam(required = false, defaultValue = "false") Boolean inStockOnly,
            @Parameter(description = "Chỉ lấy sản phẩm đang giảm giá", example = "false")
            @RequestParam(required = false, defaultValue = "false") Boolean hasDiscountOnly,
            @Parameter(description = "Tiêu chí sắp xếp: newest (mới nhất), price_asc (giá tăng dần), price_desc (giá giảm dần), rating_desc (đánh giá sao cao nhất), popular (nhiều đánh giá nhất)", example = "newest")
            @RequestParam(defaultValue = "newest") String sortBy,
            @Parameter(description = "Số trang (bắt đầu từ 1)", example = "1")
            @RequestParam(defaultValue = "1") int page,
            @Parameter(description = "Số lượng sản phẩm mỗi trang", example = "10")
            @RequestParam(defaultValue = "10") int pageSize) {

        ProductFilterRequest request = ProductFilterRequest.builder()
                .categoryId(categoryId)
                .brand(brand)
                .minPrice(minPrice)
                .maxPrice(maxPrice)
                .size(size)
                .colorCode(colorCode)
                .minRating(minRating)
                .inStockOnly(inStockOnly)
                .hasDiscountOnly(hasDiscountOnly)
                .sortBy(sortBy)
                .page(page)
                .pageSize(pageSize)
                .build();

        ProductFilterResponse response = productService.filterProducts(request);

        String message;
        if (!response.isHasResults()) {
            message = "Không tìm thấy sản phẩm nào phù hợp với bộ lọc đã chọn";
        } else {
            message = "Lọc được " + response.getTotalElements() + " sản phẩm phù hợp";
        }

        return ResponseEntity.ok(ApiResponse.success(message, response));
    }

    @GetMapping("/{id}")
    @Operation(
            summary = "UC-05: Xem chi tiết sản phẩm",
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
            summary = "UC-06: Lấy danh sách tất cả biến thể Size và Màu của sản phẩm",
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
            summary = "UC-06: Chọn biến thể sản phẩm theo Size và Màu",
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

    @GetMapping("/{id}/ratings")
    @Operation(
            summary = "UC-23: Xem đánh giá và bình luận sản phẩm",
            description = "Trả về thống kê tổng quan số sao (điểm trung bình, phân bổ 1-5 sao) và danh sách chi tiết các đánh giá, nhận xét của khách hàng. Hỗ trợ lọc theo số sao (1-5 sao), sắp xếp theo mới nhất, đánh giá cao nhất, đánh giá thấp nhất kèm phân trang."
    )
    @ApiResponses({
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "Lấy danh sách đánh giá thành công"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "404", description = "Không tìm thấy sản phẩm")
    })
    public ResponseEntity<ApiResponse<ProductRatingPageResponse>> getProductRatings(
            @Parameter(description = "Mã sản phẩm (VD: p1, p2, p3, p4)", example = "p1")
            @PathVariable String id,
            @Parameter(description = "Lọc theo số sao cụ thể (1, 2, 3, 4, 5 hoặc để trống để xem tất cả)", example = "5")
            @RequestParam(required = false) Integer star,
            @Parameter(description = "Số trang (bắt đầu từ 1)", example = "1")
            @RequestParam(defaultValue = "1") int page,
            @Parameter(description = "Số lượng đánh giá mỗi trang", example = "10")
            @RequestParam(defaultValue = "10") int size,
            @Parameter(description = "Tiêu chí sắp xếp: newest (mới nhất), highest_rating (sao cao nhất), lowest_rating (sao thấp nhất)", example = "newest")
            @RequestParam(defaultValue = "newest") String sortBy) {

        ProductRatingPageResponse response = productService.getProductRatings(id, star, page, size, sortBy);
        return ResponseEntity.ok(ApiResponse.success("Lấy danh sách đánh giá sản phẩm thành công", response));
    }

    @PostMapping("/{id}/ratings")
    @Operation(
            summary = "UC-24: Thêm đánh giá và bình luận sản phẩm",
            description = "Cho phép khách hàng gửi đánh giá số sao (1-5 sao), viết nhận xét, ghi chú size/màu đã mua và đính kèm danh sách hình ảnh thực tế. Hệ thống tự động tính toán lại điểm đánh giá trung bình và tổng số review của sản phẩm."
    )
    @ApiResponses({
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "201", description = "Thêm đánh giá thành công"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "400", description = "Dữ liệu đánh giá không hợp lệ"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "404", description = "Không tìm thấy sản phẩm")
    })
    public ResponseEntity<ApiResponse<ProductRatingDTO>> addProductRating(
            @Parameter(description = "Mã sản phẩm cần đánh giá (VD: p1, p2)", example = "p1")
            @PathVariable String id,
            @Valid @RequestBody AddRatingRequest request) {

        ProductRatingDTO rating = productService.addProductRating(id, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Đánh giá sản phẩm thành công", rating));
    }

    @PutMapping("/{id}/stock/reduce")
    @Operation(
            summary = "Inter-Service API: Trừ tồn kho sản phẩm khi tạo đơn hàng",
            description = "API nội bộ cho OrderService gọi sang khi khách hàng đặt hàng thành công để kiểm tra và trừ số lượng tồn kho (stock) của sản phẩm và biến thể Size/Màu."
    )
    public ResponseEntity<ApiResponse<ProductDTO>> reduceStock(
            @Parameter(description = "Mã sản phẩm (VD: p1, p2)", example = "p1")
            @PathVariable String id,
            @Parameter(description = "Số lượng cần trừ", example = "1")
            @RequestParam(defaultValue = "1") int quantity,
            @Parameter(description = "Kích cỡ đã chọn (VD: 41)", example = "41")
            @RequestParam(required = false) String size,
            @Parameter(description = "Mã màu đã chọn", example = "4279900698")
            @RequestParam(required = false) Long colorCode) {
        ProductDTO updated = productService.reduceStock(id, quantity, size, colorCode);
        return ResponseEntity.ok(ApiResponse.success("Trừ tồn kho sản phẩm thành công", updated));
    }

    @PutMapping("/{id}/stock/restore")
    @Operation(
            summary = "Inter-Service API: Hoàn lại tồn kho sản phẩm khi hủy đơn hàng",
            description = "API nội bộ cho OrderService gọi sang khi khách hàng hủy đơn hàng để cộng trả lại số lượng tồn kho (stock) của sản phẩm và biến thể Size/Màu."
    )
    public ResponseEntity<ApiResponse<ProductDTO>> restoreStock(
            @Parameter(description = "Mã sản phẩm (VD: p1, p2)", example = "p1")
            @PathVariable String id,
            @Parameter(description = "Số lượng cần hoàn lại", example = "1")
            @RequestParam(defaultValue = "1") int quantity,
            @Parameter(description = "Kích cỡ đã chọn (VD: 41)", example = "41")
            @RequestParam(required = false) String size,
            @Parameter(description = "Mã màu đã chọn", example = "4279900698")
            @RequestParam(required = false) Long colorCode) {
        ProductDTO updated = productService.restoreStock(id, quantity, size, colorCode);
        return ResponseEntity.ok(ApiResponse.success("Hoàn lại tồn kho sản phẩm thành công", updated));
    }
}
