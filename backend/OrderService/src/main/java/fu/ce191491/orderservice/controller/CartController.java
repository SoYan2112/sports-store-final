package fu.ce191491.orderservice.controller;

import fu.ce191491.orderservice.common.ApiResponse;
import fu.ce191491.orderservice.dto.CartItemRequest;
import fu.ce191491.orderservice.dto.CartItemResponse;
import fu.ce191491.orderservice.service.CartService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
@Tag(name = "Cart Controller", description = "APIs quản lý giỏ hàng - FE contract")
public class CartController {

    private final CartService cartService;

    @GetMapping("/cart")
    @Operation(summary = "View cart")
    public ResponseEntity<ApiResponse<List<CartItemResponse>>> getCart(
            @RequestParam(value = "userId", required = false) String userId) {
        List<CartItemResponse> items = cartService.getCart(userId);
        return ResponseEntity.ok(ApiResponse.success("Lấy giỏ hàng thành công", items));
    }

    @PostMapping("/cart/items")
    @Operation(summary = "Add product to cart")
    public ResponseEntity<ApiResponse<CartItemResponse>> addItemToCart(
            @RequestParam(value = "userId", required = false) String userId,
            @RequestBody CartItemRequest request) {
        CartItemResponse item = cartService.addItemToCart(userId, request);
        return ResponseEntity.ok(ApiResponse.success("Thêm sản phẩm vào giỏ hàng thành công", item));
    }

    @DeleteMapping("/cart/items/{id}")
    @Operation(summary = "Remove item from cart")
    public ResponseEntity<ApiResponse<List<CartItemResponse>>> removeItemFromCart(
            @PathVariable("id") String itemId,
            @RequestParam(value = "userId", required = false) String userId) {
        List<CartItemResponse> items = cartService.removeItemFromCart(userId, itemId);
        return ResponseEntity.ok(ApiResponse.success("Xóa sản phẩm khỏi giỏ hàng thành công", items));
    }
}
