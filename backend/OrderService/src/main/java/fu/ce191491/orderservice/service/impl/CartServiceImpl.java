package fu.ce191491.orderservice.service.impl;

import fu.ce191491.orderservice.common.ApiException;
import fu.ce191491.orderservice.dto.CartItemRequest;
import fu.ce191491.orderservice.dto.CartItemResponse;
import fu.ce191491.orderservice.service.CartService;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class CartServiceImpl implements CartService {

    private final Map<String, Map<String, CartItemResponse>> carts = new ConcurrentHashMap<>();

    @Override
    public List<CartItemResponse> getCart(String userId) {
        String resolvedUserId = normalizeUserId(userId);
        return new ArrayList<>(carts.getOrDefault(resolvedUserId, Map.of()).values())
                .stream()
                .sorted(Comparator.comparing(CartItemResponse::getProductId))
                .toList();
    }

    @Override
    public CartItemResponse addItemToCart(String userId, CartItemRequest request) {
        String resolvedUserId = normalizeUserId(userId);
        if (request == null) {
            throw ApiException.badRequest("Dữ liệu giỏ hàng không được để trống");
        }
        if (request.getProductId() == null || request.getProductId().isBlank()) {
            throw ApiException.badRequest("productId không được để trống");
        }
        if (request.getName() == null || request.getName().isBlank()) {
            throw ApiException.badRequest("name không được để trống");
        }
        if (request.getPrice() == null || request.getPrice() <= 0) {
            throw ApiException.badRequest("price phải lớn hơn 0");
        }

        String itemId = request.getId();
        if (itemId == null || itemId.isBlank()) {
            itemId = generateCartItemId(
                    request.getProductId(),
                    request.getSelectedSize(),
                    request.getSelectedColor() == null ? 0 : request.getSelectedColor()
            );
        }

        int quantity = request.getQuantity() == null ? 1 : Math.max(1, request.getQuantity());
        int selectedColor = request.getSelectedColor() == null ? 0xFF1A1A1A : request.getSelectedColor();

        Map<String, CartItemResponse> userCart = carts.computeIfAbsent(resolvedUserId, key -> new ConcurrentHashMap<>());
        CartItemResponse existing = userCart.get(itemId);

        if (existing != null) {
            quantity = existing.getQuantity() + quantity;
            userCart.put(itemId, CartItemResponse.builder()
                    .id(itemId)
                    .productId(request.getProductId())
                    .name(request.getName())
                    .brand(request.getBrand())
                    .price(request.getPrice())
                    .imageUrl(request.getImageUrl())
                    .selectedSize(request.getSelectedSize())
                    .selectedColor(selectedColor)
                    .quantity(quantity)
                    .stock(request.getStock() == null ? 99 : request.getStock())
                    .build());
            return userCart.get(itemId);
        }

        CartItemResponse newItem = CartItemResponse.builder()
                .id(itemId)
                .productId(request.getProductId())
                .name(request.getName())
                .brand(request.getBrand())
                .price(request.getPrice())
                .imageUrl(request.getImageUrl())
                .selectedSize(request.getSelectedSize())
                .selectedColor(selectedColor)
                .quantity(quantity)
                .stock(request.getStock() == null ? 99 : request.getStock())
                .build();

        userCart.put(itemId, newItem);
        return newItem;
    }

    @Override
    public List<CartItemResponse> removeItemFromCart(String userId, String itemId) {
        String resolvedUserId = normalizeUserId(userId);
        if (itemId == null || itemId.isBlank()) {
            throw ApiException.badRequest("itemId không được để trống");
        }

        Map<String, CartItemResponse> userCart = carts.getOrDefault(resolvedUserId, Map.of());
        if (userCart.containsKey(itemId)) {
            userCart.remove(itemId);
        }
        return new ArrayList<>(userCart.values())
                .stream()
                .sorted(Comparator.comparing(CartItemResponse::getProductId))
                .toList();
    }

    private String normalizeUserId(String userId) {
        return (userId == null || userId.isBlank()) ? "guest" : userId.trim();
    }

    private String generateCartItemId(String productId, String size, Integer selectedColor) {
        String suffix = selectedColor == null ? "0" : String.valueOf(selectedColor);
        String safeSize = size == null ? "default" : size.trim();
        return String.format("%s_%s_%s", productId, safeSize, suffix);
    }
}
