package fu.ce190435.productservice;

import fu.ce190435.productservice.common.ApiException;
import fu.ce190435.productservice.dto.ProductFilterRequest;
import fu.ce190435.productservice.dto.ProductFilterResponse;
import fu.ce190435.productservice.entity.Category;
import fu.ce190435.productservice.entity.Product;
import fu.ce190435.productservice.entity.ProductVariant;
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
class ProductServiceFilterTests {

    @Mock
    private ProductRepository productRepository;

    @Mock
    private ProductVariantRepository productVariantRepository;

    @Mock
    private fu.ce190435.productservice.repository.ProductRatingRepository productRatingRepository;

    @InjectMocks
    private ProductServiceImpl productService;

    private List<Product> mockProducts;
    private Category shoes;
    private Category tops;

    @BeforeEach
    void setUp() {
        shoes = Category.builder().id("cat_shoes").name("Giày thể thao").build();
        tops = Category.builder().id("cat_tops").name("Áo thể thao").build();

        mockProducts = List.of(
                Product.builder()
                        .id("p1")
                        .name("Nike unveil joyride")
                        .brand("Nike")
                        .price(1950000.0)
                        .originalPrice(2450000.0)
                        .rating(4.9)
                        .reviewCount(128)
                        .stock(15)
                        .category(shoes)
                        .createdAt(1000L)
                        .build(),
                Product.builder()
                        .id("p2")
                        .name("Adidas Ultraboost Light")
                        .brand("Adidas")
                        .price(3200000.0)
                        .originalPrice(null)
                        .rating(4.6)
                        .reviewCount(90)
                        .stock(0)
                        .category(shoes)
                        .createdAt(2000L)
                        .build(),
                Product.builder()
                        .id("p3")
                        .name("Nike Dri-FIT Training Tee")
                        .brand("Nike")
                        .price(750000.0)
                        .originalPrice(950000.0)
                        .rating(4.8)
                        .reviewCount(55)
                        .stock(20)
                        .category(tops)
                        .createdAt(3000L)
                        .build()
        );
    }

    @Test
    void filterProducts_byBrandNike_shouldReturnNikeProducts() {
        when(productRepository.findAll()).thenReturn(mockProducts);

        ProductFilterRequest request = ProductFilterRequest.builder()
                .brand("Nike")
                .build();

        ProductFilterResponse response = productService.filterProducts(request);

        assertNotNull(response);
        assertEquals(2, response.getTotalElements());
        assertTrue(response.isHasResults());
        assertTrue(response.getProducts().stream().allMatch(p -> p.getBrand().equalsIgnoreCase("Nike")));
    }

    @Test
    void filterProducts_byPriceRange_shouldReturnMatchingProducts() {
        when(productRepository.findAll()).thenReturn(mockProducts);

        ProductFilterRequest request = ProductFilterRequest.builder()
                .minPrice(1000000.0)
                .maxPrice(2500000.0)
                .build();

        ProductFilterResponse response = productService.filterProducts(request);

        assertNotNull(response);
        assertEquals(1, response.getTotalElements());
        assertEquals("p1", response.getProducts().get(0).getId());
    }

    @Test
    void filterProducts_byInStockOnly_shouldExcludeOutOfStock() {
        when(productRepository.findAll()).thenReturn(mockProducts);

        ProductFilterRequest request = ProductFilterRequest.builder()
                .inStockOnly(true)
                .build();

        ProductFilterResponse response = productService.filterProducts(request);

        assertNotNull(response);
        assertEquals(2, response.getTotalElements());
        assertTrue(response.getProducts().stream().noneMatch(p -> p.getId().equals("p2")));
    }

    @Test
    void filterProducts_byHasDiscountOnly_shouldReturnDiscountedOnly() {
        when(productRepository.findAll()).thenReturn(mockProducts);

        ProductFilterRequest request = ProductFilterRequest.builder()
                .hasDiscountOnly(true)
                .build();

        ProductFilterResponse response = productService.filterProducts(request);

        assertNotNull(response);
        assertEquals(2, response.getTotalElements());
        assertTrue(response.getProducts().stream().noneMatch(p -> p.getId().equals("p2")));
    }

    @Test
    void filterProducts_withInvalidPriceRange_shouldThrowBadRequest() {
        ProductFilterRequest request = ProductFilterRequest.builder()
                .minPrice(3000000.0)
                .maxPrice(1000000.0)
                .build();

        ApiException ex = assertThrows(ApiException.class, () -> productService.filterProducts(request));
        assertTrue(ex.getMessage().contains("Mức giá tối thiểu không được lớn hơn"));
    }

    @Test
    void filterProducts_bySizeViaVariants_shouldReturnMatchingProducts() {
        when(productRepository.findAll()).thenReturn(mockProducts);
        when(productVariantRepository.findBySize("41")).thenReturn(List.of(
                ProductVariant.builder()
                        .id("p1_41_black")
                        .product(mockProducts.get(0))
                        .size("41")
                        .stock(10)
                        .build()
        ));

        ProductFilterRequest request = ProductFilterRequest.builder()
                .size("41")
                .build();

        ProductFilterResponse response = productService.filterProducts(request);

        assertNotNull(response);
        assertEquals(1, response.getTotalElements());
        assertEquals("p1", response.getProducts().get(0).getId());
    }
}
