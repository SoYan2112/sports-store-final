package fu.ce190435.productservice;

import fu.ce190435.productservice.common.ApiException;
import fu.ce190435.productservice.dto.AddRatingRequest;
import fu.ce190435.productservice.dto.ProductRatingDTO;
import fu.ce190435.productservice.dto.ProductRatingPageResponse;
import fu.ce190435.productservice.entity.Category;
import fu.ce190435.productservice.entity.Product;
import fu.ce190435.productservice.entity.ProductRating;
import fu.ce190435.productservice.repository.ProductRatingRepository;
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
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProductServiceRatingTests {

    @Mock
    private ProductRepository productRepository;

    @Mock
    private ProductVariantRepository productVariantRepository;

    @Mock
    private ProductRatingRepository productRatingRepository;

    @InjectMocks
    private ProductServiceImpl productService;

    private Product mockProduct;
    private List<ProductRating> mockRatings;

    @BeforeEach
    void setUp() {
        Category shoes = Category.builder().id("cat_shoes").name("Giày thể thao").build();

        mockProduct = Product.builder()
                .id("p1")
                .name("Nike unveil joyride")
                .brand("Nike")
                .price(1950000.0)
                .rating(4.7)
                .reviewCount(3)
                .category(shoes)
                .build();

        mockRatings = List.of(
                ProductRating.builder()
                        .id("rev_1")
                        .product(mockProduct)
                        .userId("user_01")
                        .userName("Hoàng Nhật")
                        .rating(5)
                        .comment("Rất tuyệt vời!")
                        .sizeBought("41")
                        .createdAt(1000L)
                        .build(),
                ProductRating.builder()
                        .id("rev_2")
                        .product(mockProduct)
                        .userId("user_02")
                        .userName("San Yo")
                        .rating(5)
                        .comment("Đẹp chuẩn form!")
                        .sizeBought("42")
                        .createdAt(2000L)
                        .build(),
                ProductRating.builder()
                        .id("rev_3")
                        .product(mockProduct)
                        .userId("user_03")
                        .userName("Minh Khang")
                        .rating(4)
                        .comment("Tốt trong tầm giá")
                        .sizeBought("40")
                        .createdAt(3000L)
                        .build()
        );
    }

    @Test
    void getProductRatings_validProduct_shouldReturnRatingsAndSummary() {
        when(productRepository.findById("p1")).thenReturn(Optional.of(mockProduct));
        when(productRatingRepository.findByProduct_Id("p1")).thenReturn(mockRatings);

        ProductRatingPageResponse response = productService.getProductRatings("p1", null, 1, 10, "newest");

        assertNotNull(response);
        assertEquals("p1", response.getProductId());
        assertEquals(3, response.getTotalElements());
        assertEquals(3, response.getRatings().size());

        assertNotNull(response.getSummary());
        assertEquals(2, response.getSummary().getFiveStarCount());
        assertEquals(1, response.getSummary().getFourStarCount());
        assertEquals(0, response.getSummary().getThreeStarCount());
        assertEquals(4.7, response.getSummary().getAverageRating());
    }

    @Test
    void getProductRatings_filterByStar5_shouldReturnOnly5StarRatings() {
        when(productRepository.findById("p1")).thenReturn(Optional.of(mockProduct));
        when(productRatingRepository.findByProduct_Id("p1")).thenReturn(mockRatings);

        ProductRatingPageResponse response = productService.getProductRatings("p1", 5, 1, 10, "newest");

        assertNotNull(response);
        assertEquals(2, response.getTotalElements());
        assertEquals(2, response.getRatings().size());
        assertTrue(response.getRatings().stream().allMatch(r -> r.getRating() == 5));
    }

    @Test
    void getProductRatings_nonExistentProduct_shouldThrowNotFound() {
        when(productRepository.findById("p_non_exist")).thenReturn(Optional.empty());

        ApiException ex = assertThrows(ApiException.class,
                () -> productService.getProductRatings("p_non_exist", null, 1, 10, "newest"));
        assertTrue(ex.getMessage().contains("Không tìm thấy sản phẩm"));
    }

    @Test
    void addProductRating_validRequest_shouldSaveRatingAndRecalculateProductStats() {
        when(productRepository.findById("p1")).thenReturn(Optional.of(mockProduct));
        when(productRatingRepository.save(any(ProductRating.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // After adding, repository has 4 ratings
        ProductRating newRating = ProductRating.builder()
                .id("rev_new")
                .product(mockProduct)
                .rating(5)
                .build();
        when(productRatingRepository.findByProduct_Id("p1")).thenReturn(List.of(
                mockRatings.get(0), mockRatings.get(1), mockRatings.get(2), newRating
        ));

        AddRatingRequest request = AddRatingRequest.builder()
                .userId("user_04")
                .userName("Anh Tuấn")
                .rating(5)
                .comment("Hài lòng!")
                .sizeBought("41")
                .colorBought("Đen")
                .images(List.of("https://image1.jpg"))
                .build();

        ProductRatingDTO result = productService.addProductRating("p1", request);

        assertNotNull(result);
        assertEquals("user_04", result.getUserId());
        assertEquals("Anh Tuấn", result.getUserName());
        assertEquals(5, result.getRating());

        verify(productRatingRepository, times(1)).save(any(ProductRating.class));
        verify(productRepository, times(1)).save(mockProduct);
        assertEquals(4, mockProduct.getReviewCount());
    }

    @Test
    void addProductRating_invalidRatingValue_shouldThrowBadRequest() {
        when(productRepository.findById("p1")).thenReturn(Optional.of(mockProduct));

        AddRatingRequest request = AddRatingRequest.builder()
                .userId("user_01")
                .userName("Test")
                .rating(6) // Invalid rating
                .build();

        ApiException ex = assertThrows(ApiException.class, () -> productService.addProductRating("p1", request));
        assertTrue(ex.getMessage().contains("Số sao đánh giá phải từ 1 đến 5 sao"));
    }
}
