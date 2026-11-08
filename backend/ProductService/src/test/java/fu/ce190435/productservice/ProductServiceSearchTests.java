package fu.ce190435.productservice;

import fu.ce190435.productservice.dto.ProductSearchResponse;
import fu.ce190435.productservice.entity.Category;
import fu.ce190435.productservice.entity.Product;
import fu.ce190435.productservice.repository.ProductRepository;
import fu.ce190435.productservice.repository.ProductVariantRepository;
import fu.ce190435.productservice.service.impl.ProductServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ProductServiceSearchTests {

    @Mock
    private ProductRepository productRepository;

    @Mock
    private ProductVariantRepository productVariantRepository;

    @Mock
    private fu.ce190435.productservice.repository.ProductRatingRepository productRatingRepository;

    @InjectMocks
    private ProductServiceImpl productService;

    private List<Product> mockProducts;

    @BeforeEach
    void setUp() {
        Category shoes = Category.builder().id("cat_shoes").name("Giày thể thao").build();
        Category tops = Category.builder().id("cat_tops").name("Áo thể thao").build();

        mockProducts = List.of(
                Product.builder()
                        .id("p1")
                        .name("Nike unveil joyride")
                        .brand("Nike")
                        .price(1950000.0)
                        .rating(4.9)
                        .category(shoes)
                        .createdAt(1000L)
                        .build(),
                Product.builder()
                        .id("p2")
                        .name("Adidas Ultraboost Light")
                        .brand("Adidas")
                        .price(3200000.0)
                        .rating(4.8)
                        .category(shoes)
                        .createdAt(2000L)
                        .build(),
                Product.builder()
                        .id("p3")
                        .name("Nike Dri-FIT Training Tee")
                        .brand("Nike")
                        .price(750000.0)
                        .rating(4.7)
                        .category(tops)
                        .createdAt(3000L)
                        .build()
        );
    }

    @Test
    void searchProducts_byKeywordNike_shouldReturnMatchingProducts() {
        when(productRepository.findAll()).thenReturn(mockProducts);

        ProductSearchResponse response = productService.searchProducts("Nike", 1, 10, "relevance");

        assertNotNull(response);
        assertEquals("Nike", response.getKeyword());
        assertEquals(2, response.getTotalElements());
        assertEquals(2, response.getProducts().size());
        assertTrue(response.getProducts().stream().allMatch(p -> p.getBrand().equalsIgnoreCase("Nike")));
    }

    @Test
    void searchProducts_withSortPriceAsc_shouldReturnSortedByPrice() {
        when(productRepository.findAll()).thenReturn(mockProducts);

        ProductSearchResponse response = productService.searchProducts("Nike", 1, 10, "price_asc");

        assertNotNull(response);
        assertEquals(2, response.getProducts().size());
        assertEquals("p3", response.getProducts().get(0).getId()); // 750,000 < 1,950,000
        assertEquals("p1", response.getProducts().get(1).getId());
    }

    @Test
    void searchProducts_withEmptyKeyword_shouldReturnAllProducts() {
        when(productRepository.findAll()).thenReturn(mockProducts);

        ProductSearchResponse response = productService.searchProducts("", 1, 10, "relevance");

        assertNotNull(response);
        assertEquals(3, response.getTotalElements());
        assertEquals(3, response.getProducts().size());
        assertTrue(response.isHasResults());
    }

    @Test
    void searchProducts_withNoMatchingKeyword_shouldReturnEmptyAndHasResultsFalse() {
        when(productRepository.findAll()).thenReturn(mockProducts);

        ProductSearchResponse response = productService.searchProducts("UnmatchedKey999", 1, 10, "relevance");

        assertNotNull(response);
        assertEquals(0, response.getTotalElements());
        assertEquals(0, response.getProducts().size());
        assertFalse(response.isHasResults());
    }
}
