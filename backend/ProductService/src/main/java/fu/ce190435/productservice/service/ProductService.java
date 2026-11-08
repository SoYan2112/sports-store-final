package fu.ce190435.productservice.service;

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

import java.util.List;

public interface ProductService {
    List<ProductDTO> getProducts(int page, int size, String categoryId, String keyword);

    ProductDetailDTO getProductById(String id);

    List<ProductVariantDTO> getProductVariants(String productId);

    SelectVariantResponse selectProductVariant(String productId, String size, Long colorCode);

    ProductSearchResponse searchProducts(String keyword, int page, int size, String sortBy);

    ProductFilterResponse filterProducts(ProductFilterRequest request);

    ProductRatingPageResponse getProductRatings(String productId, Integer star, int page, int size, String sortBy);

    ProductRatingDTO addProductRating(String productId, AddRatingRequest request);
}
