package fu.ce190435.productservice.service;

import fu.ce190435.productservice.dto.ProductDTO;
import fu.ce190435.productservice.dto.ProductDetailDTO;
import fu.ce190435.productservice.dto.ProductVariantDTO;
import fu.ce190435.productservice.dto.SelectVariantResponse;

import java.util.List;

public interface ProductService {
    List<ProductDTO> getProducts(int page, int size, String categoryId, String keyword);

    ProductDetailDTO getProductById(String id);

    List<ProductVariantDTO> getProductVariants(String productId);

    SelectVariantResponse selectProductVariant(String productId, String size, Long colorCode);
}
