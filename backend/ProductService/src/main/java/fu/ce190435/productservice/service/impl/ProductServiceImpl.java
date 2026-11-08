package fu.ce190435.productservice.service.impl;

import fu.ce190435.productservice.common.ApiException;
import fu.ce190435.productservice.dto.ProductDTO;
import fu.ce190435.productservice.dto.ProductDetailDTO;
import fu.ce190435.productservice.dto.ProductVariantDTO;
import fu.ce190435.productservice.dto.SelectVariantResponse;
import fu.ce190435.productservice.entity.Product;
import fu.ce190435.productservice.entity.ProductVariant;
import fu.ce190435.productservice.repository.ProductRepository;
import fu.ce190435.productservice.repository.ProductVariantRepository;
import fu.ce190435.productservice.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;
    private final ProductVariantRepository productVariantRepository;

    @Override
    @Transactional(readOnly = true)
    public List<ProductDTO> getProducts(int page, int size, String categoryId, String keyword) {
        int safePage = Math.max(page, 1);
        int safeSize = Math.max(size, 1);

        List<Product> allProducts = productRepository.findAll();

        if (categoryId != null && !categoryId.isBlank()) {
            String catFilter = categoryId.trim().toLowerCase(Locale.ROOT);
            allProducts = allProducts.stream()
                    .filter(p -> matchesCategory(p, catFilter))
                    .collect(Collectors.toList());
        }

        if (keyword != null && !keyword.isBlank()) {
            String q = keyword.trim().toLowerCase(Locale.ROOT);
            allProducts = allProducts.stream()
                    .filter(p -> matchesKeyword(p, q))
                    .collect(Collectors.toList());
        }

        int startIndex = (safePage - 1) * safeSize;
        if (startIndex >= allProducts.size()) {
            return Collections.emptyList();
        }
        int endIndex = Math.min(startIndex + safeSize, allProducts.size());

        return allProducts.subList(startIndex, endIndex)
                .stream()
                .map(this::toProductDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public ProductDetailDTO getProductById(String id) {
        if (id == null || id.isBlank()) {
            throw ApiException.badRequest("Mã sản phẩm không được để trống");
        }

        Product product = productRepository.findById(id.trim())
                .orElseThrow(() -> ApiException.notFound("Không tìm thấy sản phẩm với mã: " + id));

        return toProductDetailDTO(product);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ProductVariantDTO> getProductVariants(String productId) {
        if (productId == null || productId.isBlank()) {
            throw ApiException.badRequest("Mã sản phẩm không được để trống");
        }
        if (!productRepository.existsById(productId.trim())) {
            throw ApiException.notFound("Không tìm thấy sản phẩm với mã: " + productId);
        }

        List<ProductVariant> variants = productVariantRepository.findByProduct_Id(productId.trim());
        return variants.stream()
                .map(this::toProductVariantDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public SelectVariantResponse selectProductVariant(String productId, String size, Long colorCode) {
        if (productId == null || productId.isBlank()) {
            throw ApiException.badRequest("Mã sản phẩm không được để trống");
        }
        if (size == null || size.isBlank()) {
            throw ApiException.badRequest("Vui lòng chọn kích cỡ (Size)");
        }

        Product product = productRepository.findById(productId.trim())
                .orElseThrow(() -> ApiException.notFound("Không tìm thấy sản phẩm với mã: " + productId));

        Long targetColor = colorCode != null ? colorCode : 0xFF1A1A1AL;
        String cleanSize = size.trim();

        ProductVariant variant = productVariantRepository
                .findByProduct_IdAndSizeAndColorCode(product.getId(), cleanSize, targetColor)
                .orElseGet(() -> ProductVariant.builder()
                        .id(product.getId() + "_" + cleanSize + "_" + targetColor)
                        .product(product)
                        .size(cleanSize)
                        .colorCode(targetColor)
                        .colorName("Mặc định")
                        .stock(product.getStock() != null ? product.getStock() : 12)
                        .price(product.getPrice())
                        .build());

        List<ProductVariant> allVariants = productVariantRepository.findByProduct_Id(product.getId());
        List<String> availableSizes = allVariants.isEmpty()
                ? List.of("38", "39", "40", "41", "42", "43")
                : allVariants.stream().map(ProductVariant::getSize).distinct().collect(Collectors.toList());
        List<Long> availableColors = allVariants.isEmpty()
                ? List.of(0xFF1A1A1AL, 0xFFFFFFFFL, 0xFFFF6B00L, 0xFF1E88E5L)
                : allVariants.stream().map(ProductVariant::getColorCode).distinct().collect(Collectors.toList());

        int stock = variant.getStock() != null ? variant.getStock() : 0;

        return SelectVariantResponse.builder()
                .variantId(variant.getId())
                .productId(product.getId())
                .productName(product.getName())
                .selectedSize(variant.getSize())
                .selectedColorCode(variant.getColorCode())
                .selectedColorName(variant.getColorName())
                .price(variant.getPrice() != null ? variant.getPrice() : product.getPrice())
                .stock(stock)
                .inStock(stock > 0)
                .availableSizes(availableSizes)
                .availableColors(availableColors)
                .build();
    }

    private ProductVariantDTO toProductVariantDTO(ProductVariant variant) {
        int stock = variant.getStock() != null ? variant.getStock() : 0;
        return ProductVariantDTO.builder()
                .id(variant.getId())
                .productId(variant.getProduct() != null ? variant.getProduct().getId() : null)
                .size(variant.getSize())
                .colorCode(variant.getColorCode())
                .colorName(variant.getColorName())
                .stock(stock)
                .price(variant.getPrice())
                .inStock(stock > 0)
                .build();
    }

    private ProductDetailDTO toProductDetailDTO(Product product) {
        List<String> gallery = List.of(
                product.getImageUrl(),
                "https://images.unsplash.com/photo-1514989940723-e8e51635b782?w=600&auto=format&fit=crop&q=80",
                "https://images.unsplash.com/photo-1600185365926-3a2ce3cdb9eb?w=600&auto=format&fit=crop&q=80",
                "https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=600&auto=format&fit=crop&q=80");

        boolean hasDiscount = product.getOriginalPrice() != null
                && product.getPrice() != null
                && product.getOriginalPrice() > product.getPrice();

        int discountPercentage = 0;
        if (hasDiscount) {
            discountPercentage = (int) Math.round(
                    ((product.getOriginalPrice() - product.getPrice()) / product.getOriginalPrice()) * 100);
        }

        return ProductDetailDTO.builder()
                .id(product.getId())
                .name(product.getName())
                .brand(product.getBrand())
                .price(product.getPrice())
                .originalPrice(product.getOriginalPrice())
                .imageUrl(product.getImageUrl())
                .badge(product.getBadge())
                .rating(product.getRating())
                .reviewCount(product.getReviewCount())
                .description(product.getDescription())
                .images(gallery)
                .category(product.getCategory() != null ? product.getCategory().getName() : "Giày thể thao")
                .categoryId(product.getCategory() != null ? product.getCategory().getId() : "cat_shoes")
                .stock(product.getStock() != null ? product.getStock() : 15)
                .sizes(List.of("38", "39", "40", "41", "42", "43"))
                .colors(List.of(0xFF1A1A1AL, 0xFFFFFFFFL, 0xFFFF6B00L, 0xFF1E88E5L))
                .hasDiscount(hasDiscount)
                .discountPercentage(discountPercentage)
                .build();
    }

    private boolean matchesCategory(Product product, String catFilter) {
        if (product.getCategory() == null) {
            return false;
        }
        String catId = product.getCategory().getId() != null
                ? product.getCategory().getId().toLowerCase(Locale.ROOT)
                : "";
        String catName = product.getCategory().getName() != null
                ? product.getCategory().getName().toLowerCase(Locale.ROOT)
                : "";
        return catId.equals(catFilter) || catName.contains(catFilter);
    }

    private boolean matchesKeyword(Product product, String keyword) {
        String name = product.getName() != null ? product.getName().toLowerCase(Locale.ROOT) : "";
        String brand = product.getBrand() != null ? product.getBrand().toLowerCase(Locale.ROOT) : "";
        String catName = (product.getCategory() != null && product.getCategory().getName() != null)
                ? product.getCategory().getName().toLowerCase(Locale.ROOT)
                : "";
        return name.contains(keyword) || brand.contains(keyword) || catName.contains(keyword);
    }

    private ProductDTO toProductDTO(Product product) {
        return ProductDTO.builder()
                .id(product.getId())
                .name(product.getName())
                .brand(product.getBrand())
                .price(product.getPrice())
                .originalPrice(product.getOriginalPrice())
                .imageUrl(product.getImageUrl())
                .badge(product.getBadge())
                .rating(product.getRating())
                .reviewCount(product.getReviewCount())
                .description(product.getDescription())
                .category(product.getCategory() != null ? product.getCategory().getName() : "Giày thể thao")
                .categoryId(product.getCategory() != null ? product.getCategory().getId() : "cat_shoes")
                .stock(product.getStock())
                .build();
    }
}
