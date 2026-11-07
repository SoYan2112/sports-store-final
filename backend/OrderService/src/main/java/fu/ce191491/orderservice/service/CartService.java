package fu.ce191491.orderservice.service;

import fu.ce191491.orderservice.dto.CartItemRequest;
import fu.ce191491.orderservice.dto.CartItemResponse;

import java.util.List;

public interface CartService {
    List<CartItemResponse> getCart(String userId);

    CartItemResponse addItemToCart(String userId, CartItemRequest request);

    List<CartItemResponse> removeItemFromCart(String userId, String itemId);
}
