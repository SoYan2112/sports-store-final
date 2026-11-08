package fu.ce191491.orderservice.controller;

import fu.ce191491.orderservice.dto.CartItemRequest;
import fu.ce191491.orderservice.dto.CartItemResponse;
import fu.ce191491.orderservice.service.impl.CartServiceImpl;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class CartControllerTest {

    private final CartServiceImpl cartService = new CartServiceImpl();

    @Test
    void addItemToCart_shouldPersistRequiredFields_forFeContract() {
        CartItemRequest request = CartItemRequest.builder()
                .id("p1_M_123")
                .productId("p1")
                .name("Running Shoes")
                .brand("Nike")
                .price(190000.0)
                .imageUrl("https://example.com/image.png")
                .selectedSize("M")
                .selectedColor(0xFF123456)
                .quantity(1)
                .stock(10)
                .build();

        CartItemResponse response = cartService.addItemToCart("user-1", request);

        assertNotNull(response);
        assertEquals("p1", response.getProductId());
        assertEquals("M", response.getSelectedSize());
        assertEquals(0xFF123456, response.getSelectedColor());
        assertEquals(1, response.getQuantity());
    }

    @Test
    void removeItemFromCart_shouldReturnRemainingItems() {
        cartService.addItemToCart("user-1", CartItemRequest.builder()
                .id("p1_M_123")
                .productId("p1")
                .name("Running Shoes")
                .brand("Nike")
                .price(190000.0)
                .imageUrl("https://example.com/image.png")
                .selectedSize("M")
                .selectedColor(0xFF123456)
                .quantity(1)
                .stock(10)
                .build());

        List<CartItemResponse> items = cartService.removeItemFromCart("user-1", "p1_M_123");

        assertEquals(0, items.size());
    }
}
