package fu.ce190435.productservice.service.impl;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import fu.ce190435.productservice.common.ApiException;
import fu.ce190435.productservice.dto.AddRatingRequest;
import fu.ce190435.productservice.dto.FilterAppliedDTO;
import fu.ce190435.productservice.dto.ProductDTO;
import fu.ce190435.productservice.dto.ProductDetailDTO;
import fu.ce190435.productservice.dto.ProductFilterRequest;
import fu.ce190435.productservice.dto.ProductFilterResponse;
import fu.ce190435.productservice.dto.ProductRatingDTO;
import fu.ce190435.productservice.dto.ProductRatingPageResponse;
import fu.ce190435.productservice.dto.ProductSearchResponse;
import fu.ce190435.productservice.dto.ProductVariantDTO;
import fu.ce190435.productservice.dto.RatingSummaryDTO;
import fu.ce190435.productservice.dto.SelectVariantResponse;
import fu.ce190435.productservice.entity.Product;
import fu.ce190435.productservice.entity.ProductRating;
import fu.ce190435.productservice.entity.ProductVariant;
import fu.ce190435.productservice.repository.ProductRatingRepository;
import fu.ce190435.productservice.repository.ProductRepository;
import fu.ce190435.productservice.repository.ProductVariantRepository;
import fu.ce190435.productservice.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;
    private final ProductVariantRepository productVariantRepository;
    private final ProductRatingRepository productRatingRepository;

    private final ObjectMapper objectMapper = new ObjectMapper();

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

    @Override
    @Transactional(readOnly = true)
    public ProductSearchResponse searchProducts(String keyword, int page, int size, String sortBy) {
        int safePage = Math.max(page, 1);
        int safeSize = Math.max(size, 1);
        String cleanKeyword = (keyword != null) ? keyword.trim() : "";
        String lowerKeyword = cleanKeyword.toLowerCase(Locale.ROOT);

        List<Product> allProducts = productRepository.findAll();

        List<Product> matchedProducts;
        if (cleanKeyword.isEmpty()) {
            matchedProducts = new ArrayList<>(allProducts);
        } else {
            matchedProducts = allProducts.stream()
                    .filter(p -> matchesKeyword(p, lowerKeyword))
                    .collect(Collectors.toList());
        }

        String sortCriteria = (sortBy != null && !sortBy.isBlank()) ? sortBy.trim().toLowerCase(Locale.ROOT) : "relevance";
        switch (sortCriteria) {
            case "price_asc":
                matchedProducts.sort(Comparator.comparing(p -> p.getPrice() != null ? p.getPrice() : Double.MAX_VALUE));
                break;
            case "price_desc":
                matchedProducts.sort((p1, p2) -> {
                    Double price1 = p1.getPrice() != null ? p1.getPrice() : 0.0;
                    Double price2 = p2.getPrice() != null ? p2.getPrice() : 0.0;
                    return price2.compareTo(price1);
                });
                break;
            case "rating_desc":
                matchedProducts.sort((p1, p2) -> {
                    Double r1 = p1.getRating() != null ? p1.getRating() : 0.0;
                    Double r2 = p2.getRating() != null ? p2.getRating() : 0.0;
                    return r2.compareTo(r1);
                });
                break;
            case "newest":
                matchedProducts.sort((p1, p2) -> {
                    Long t1 = p1.getCreatedAt() != null ? p1.getCreatedAt() : 0L;
                    Long t2 = p2.getCreatedAt() != null ? p2.getCreatedAt() : 0L;
                    return t2.compareTo(t1);
                });
                break;
            case "relevance":
            default:
                if (!cleanKeyword.isEmpty()) {
                    matchedProducts.sort(Comparator.comparingInt(p -> calculateRelevanceScore(p, lowerKeyword)));
                }
                break;
        }

        int totalElements = matchedProducts.size();
        boolean hasResults = totalElements > 0;
        int totalPages = totalElements == 0 ? 0 : (int) Math.ceil((double) totalElements / (double) safeSize);

        int startIndex = (safePage - 1) * safeSize;
        List<ProductDTO> pagedProducts;
        if (startIndex >= totalElements) {
            pagedProducts = Collections.emptyList();
        } else {
            int endIndex = Math.min(startIndex + safeSize, totalElements);
            pagedProducts = matchedProducts.subList(startIndex, endIndex)
                    .stream()
                    .map(this::toProductDTO)
                    .collect(Collectors.toList());
        }

        return ProductSearchResponse.builder()
                .keyword(cleanKeyword)
                .totalElements(totalElements)
                .hasResults(hasResults)
                .page(safePage)
                .size(safeSize)
                .totalPages(totalPages)
                .sortBy(sortCriteria)
                .products(pagedProducts)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public ProductFilterResponse filterProducts(ProductFilterRequest request) {
        if (request == null) {
            request = new ProductFilterRequest();
        }

        if (request.getMinPrice() != null && request.getMaxPrice() != null
                && request.getMinPrice() > request.getMaxPrice()) {
            throw ApiException.badRequest("Mức giá tối thiểu không được lớn hơn mức giá tối đa");
        }

        int safePage = (request.getPage() != null && request.getPage() > 0) ? request.getPage() : 1;
        int safeSize = (request.getPageSize() != null && request.getPageSize() > 0) ? request.getPageSize() : 10;

        List<Product> allProducts = productRepository.findAll();

        if (request.getCategoryId() != null && !request.getCategoryId().isBlank()) {
            String catFilter = request.getCategoryId().trim().toLowerCase(Locale.ROOT);
            allProducts = allProducts.stream()
                    .filter(p -> matchesCategory(p, catFilter))
                    .collect(Collectors.toList());
        }

        if (request.getBrand() != null && !request.getBrand().isBlank()) {
            String brandFilter = request.getBrand().trim().toLowerCase(Locale.ROOT);
            allProducts = allProducts.stream()
                    .filter(p -> p.getBrand() != null && p.getBrand().trim().toLowerCase(Locale.ROOT).equals(brandFilter))
                    .collect(Collectors.toList());
        }

        if (request.getMinPrice() != null) {
            double minP = request.getMinPrice();
            allProducts = allProducts.stream()
                    .filter(p -> p.getPrice() != null && p.getPrice() >= minP)
                    .collect(Collectors.toList());
        }

        if (request.getMaxPrice() != null) {
            double maxP = request.getMaxPrice();
            allProducts = allProducts.stream()
                    .filter(p -> p.getPrice() != null && p.getPrice() <= maxP)
                    .collect(Collectors.toList());
        }

        if (request.getMinRating() != null) {
            double minR = request.getMinRating();
            allProducts = allProducts.stream()
                    .filter(p -> p.getRating() != null && p.getRating() >= minR)
                    .collect(Collectors.toList());
        }

        if (Boolean.TRUE.equals(request.getInStockOnly())) {
            allProducts = allProducts.stream()
                    .filter(p -> p.getStock() != null && p.getStock() > 0)
                    .collect(Collectors.toList());
        }

        if (Boolean.TRUE.equals(request.getHasDiscountOnly())) {
            allProducts = allProducts.stream()
                    .filter(p -> p.getOriginalPrice() != null && p.getPrice() != null && p.getOriginalPrice() > p.getPrice())
                    .collect(Collectors.toList());
        }

        boolean hasSizeFilter = request.getSize() != null && !request.getSize().isBlank();
        boolean hasColorFilter = request.getColorCode() != null;

        if (hasSizeFilter || hasColorFilter) {
            String cleanSize = hasSizeFilter ? request.getSize().trim() : null;
            Long cleanColor = hasColorFilter ? request.getColorCode() : null;

            List<ProductVariant> matchedVariants;
            if (hasSizeFilter && hasColorFilter) {
                matchedVariants = productVariantRepository.findBySizeAndColorCode(cleanSize, cleanColor);
            } else if (hasSizeFilter) {
                matchedVariants = productVariantRepository.findBySize(cleanSize);
            } else {
                matchedVariants = productVariantRepository.findByColorCode(cleanColor);
            }

            Set<String> matchedProductIds = matchedVariants.stream()
                    .filter(v -> v.getProduct() != null && v.getStock() != null && v.getStock() > 0)
                    .map(v -> v.getProduct().getId())
                    .collect(Collectors.toSet());

            allProducts = allProducts.stream()
                    .filter(p -> matchedProductIds.contains(p.getId()))
                    .collect(Collectors.toList());
        }

        String sortBy = (request.getSortBy() != null && !request.getSortBy().isBlank())
                ? request.getSortBy().trim().toLowerCase(Locale.ROOT)
                : "newest";

        switch (sortBy) {
            case "price_asc":
                allProducts.sort(Comparator.comparing(p -> p.getPrice() != null ? p.getPrice() : Double.MAX_VALUE));
                break;
            case "price_desc":
                allProducts.sort((p1, p2) -> {
                    Double price1 = p1.getPrice() != null ? p1.getPrice() : 0.0;
                    Double price2 = p2.getPrice() != null ? p2.getPrice() : 0.0;
                    return price2.compareTo(price1);
                });
                break;
            case "rating_desc":
                allProducts.sort((p1, p2) -> {
                    Double r1 = p1.getRating() != null ? p1.getRating() : 0.0;
                    Double r2 = p2.getRating() != null ? p2.getRating() : 0.0;
                    return r2.compareTo(r1);
                });
                break;
            case "popular":
                allProducts.sort((p1, p2) -> {
                    Integer c1 = p1.getReviewCount() != null ? p1.getReviewCount() : 0;
                    Integer c2 = p2.getReviewCount() != null ? p2.getReviewCount() : 0;
                    return c2.compareTo(c1);
                });
                break;
            case "newest":
            default:
                allProducts.sort((p1, p2) -> {
                    Long t1 = p1.getCreatedAt() != null ? p1.getCreatedAt() : 0L;
                    Long t2 = p2.getCreatedAt() != null ? p2.getCreatedAt() : 0L;
                    return t2.compareTo(t1);
                });
                break;
        }

        int totalElements = allProducts.size();
        boolean hasResults = totalElements > 0;
        int totalPages = totalElements == 0 ? 0 : (int) Math.ceil((double) totalElements / (double) safeSize);

        int startIndex = (safePage - 1) * safeSize;
        List<ProductDTO> pagedProducts;
        if (startIndex >= totalElements) {
            pagedProducts = Collections.emptyList();
        } else {
            int endIndex = Math.min(startIndex + safeSize, totalElements);
            pagedProducts = allProducts.subList(startIndex, endIndex)
                    .stream()
                    .map(this::toProductDTO)
                    .collect(Collectors.toList());
        }

        FilterAppliedDTO appliedFilters = FilterAppliedDTO.builder()
                .categoryId(request.getCategoryId())
                .brand(request.getBrand())
                .minPrice(request.getMinPrice())
                .maxPrice(request.getMaxPrice())
                .size(request.getSize())
                .colorCode(request.getColorCode())
                .minRating(request.getMinRating())
                .inStockOnly(request.getInStockOnly())
                .hasDiscountOnly(request.getHasDiscountOnly())
                .sortBy(sortBy)
                .build();

        return ProductFilterResponse.builder()
                .totalElements(totalElements)
                .hasResults(hasResults)
                .page(safePage)
                .size(safeSize)
                .totalPages(totalPages)
                .appliedFilters(appliedFilters)
                .products(pagedProducts)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public ProductRatingPageResponse getProductRatings(String productId, Integer star, int page, int size, String sortBy) {
        if (productId == null || productId.isBlank()) {
            throw ApiException.badRequest("Mã sản phẩm không được để trống");
        }

        Product product = productRepository.findById(productId.trim())
                .orElseThrow(() -> ApiException.notFound("Không tìm thấy sản phẩm với mã: " + productId));

        List<ProductRating> allRatings = productRatingRepository.findByProduct_Id(product.getId());

        int totalReviews = allRatings.size();
        int fiveStar = (int) allRatings.stream().filter(r -> r.getRating() != null && r.getRating() == 5).count();
        int fourStar = (int) allRatings.stream().filter(r -> r.getRating() != null && r.getRating() == 4).count();
        int threeStar = (int) allRatings.stream().filter(r -> r.getRating() != null && r.getRating() == 3).count();
        int twoStar = (int) allRatings.stream().filter(r -> r.getRating() != null && r.getRating() == 2).count();
        int oneStar = (int) allRatings.stream().filter(r -> r.getRating() != null && r.getRating() == 1).count();

        double avgRating = totalReviews > 0
                ? allRatings.stream().mapToInt(ProductRating::getRating).average().orElse(5.0)
                : (product.getRating() != null ? product.getRating() : 5.0);
        avgRating = Math.round(avgRating * 10.0) / 10.0;

        int finalTotalReviews = totalReviews > 0 ? totalReviews : (product.getReviewCount() != null ? product.getReviewCount() : 0);

        RatingSummaryDTO summary = RatingSummaryDTO.builder()
                .averageRating(avgRating)
                .totalReviews(finalTotalReviews)
                .fiveStarCount(fiveStar)
                .fourStarCount(fourStar)
                .threeStarCount(threeStar)
                .twoStarCount(twoStar)
                .oneStarCount(oneStar)
                .build();

        List<ProductRating> filtered = new ArrayList<>(allRatings);
        if (star != null && star >= 1 && star <= 5) {
            filtered = filtered.stream()
                    .filter(r -> r.getRating() != null && r.getRating().equals(star))
                    .collect(Collectors.toList());
        }

        String sort = (sortBy != null && !sortBy.isBlank()) ? sortBy.trim().toLowerCase(Locale.ROOT) : "newest";
        switch (sort) {
            case "highest_rating":
                filtered.sort((r1, r2) -> Integer.compare(r2.getRating() != null ? r2.getRating() : 0, r1.getRating() != null ? r1.getRating() : 0));
                break;
            case "lowest_rating":
                filtered.sort((r1, r2) -> Integer.compare(r1.getRating() != null ? r1.getRating() : 0, r2.getRating() != null ? r2.getRating() : 0));
                break;
            case "newest":
            default:
                filtered.sort((r1, r2) -> Long.compare(r2.getCreatedAt() != null ? r2.getCreatedAt() : 0L, r1.getCreatedAt() != null ? r1.getCreatedAt() : 0L));
                break;
        }

        int safePage = Math.max(page, 1);
        int safeSize = Math.max(size, 1);
        int filteredTotal = filtered.size();
        int totalPages = filteredTotal == 0 ? 0 : (int) Math.ceil((double) filteredTotal / (double) safeSize);

        int startIndex = (safePage - 1) * safeSize;
        List<ProductRatingDTO> pagedRatings;
        if (startIndex >= filteredTotal) {
            pagedRatings = Collections.emptyList();
        } else {
            int endIndex = Math.min(startIndex + safeSize, filteredTotal);
            pagedRatings = filtered.subList(startIndex, endIndex)
                    .stream()
                    .map(this::toProductRatingDTO)
                    .collect(Collectors.toList());
        }

        return ProductRatingPageResponse.builder()
                .productId(product.getId())
                .productName(product.getName())
                .summary(summary)
                .filteredStar(star)
                .page(safePage)
                .size(safeSize)
                .totalPages(totalPages)
                .totalElements(filteredTotal)
                .ratings(pagedRatings)
                .build();
    }

    @Override
    @Transactional
    public ProductRatingDTO addProductRating(String productId, AddRatingRequest request) {
        if (productId == null || productId.isBlank()) {
            throw ApiException.badRequest("Mã sản phẩm không được để trống");
        }
        if (request == null) {
            throw ApiException.badRequest("Dữ liệu đánh giá không được để trống");
        }

        Product product = productRepository.findById(productId.trim())
                .orElseThrow(() -> ApiException.notFound("Không tìm thấy sản phẩm với mã: " + productId));

        if (request.getRating() == null || request.getRating() < 1 || request.getRating() > 5) {
            throw ApiException.badRequest("Số sao đánh giá phải từ 1 đến 5 sao");
        }
        if (request.getUserId() == null || request.getUserId().isBlank()) {
            throw ApiException.badRequest("Mã người dùng không được để trống");
        }
        if (request.getUserName() == null || request.getUserName().isBlank()) {
            throw ApiException.badRequest("Tên người dùng không được để trống");
        }

        String ratingId = "rev_" + UUID.randomUUID().toString().substring(0, 8);
        long now = System.currentTimeMillis();

        ProductRating ratingEntity = ProductRating.builder()
                .id(ratingId)
                .product(product)
                .userId(request.getUserId().trim())
                .userName(request.getUserName().trim())
                .userAvatar(request.getUserAvatar())
                .rating(request.getRating())
                .comment(request.getComment() != null ? request.getComment().trim() : "")
                .sizeBought(request.getSizeBought())
                .colorBought(request.getColorBought())
                .imagesJson(writeImagesJson(request.getImages()))
                .createdAt(now)
                .build();

        ProductRating savedRating = productRatingRepository.save(ratingEntity);

        // Recalculate average rating & review count for the product
        List<ProductRating> allRatings = productRatingRepository.findByProduct_Id(product.getId());
        double avg = allRatings.stream().mapToInt(ProductRating::getRating).average().orElse(request.getRating());
        double roundedAvg = Math.round(avg * 10.0) / 10.0;

        product.setRating(roundedAvg);
        product.setReviewCount(allRatings.size());
        productRepository.save(product);

        return toProductRatingDTO(savedRating);
    }

    private ProductRatingDTO toProductRatingDTO(ProductRating rating) {
        return ProductRatingDTO.builder()
                .id(rating.getId())
                .productId(rating.getProduct() != null ? rating.getProduct().getId() : null)
                .userId(rating.getUserId())
                .userName(rating.getUserName())
                .userAvatar(rating.getUserAvatar())
                .rating(rating.getRating())
                .comment(rating.getComment())
                .sizeBought(rating.getSizeBought())
                .colorBought(rating.getColorBought())
                .images(parseImagesJson(rating.getImagesJson()))
                .createdAt(rating.getCreatedAt())
                .build();
    }

    private List<String> parseImagesJson(String json) {
        if (json == null || json.isBlank()) return Collections.emptyList();
        try {
            return objectMapper.readValue(json, new TypeReference<List<String>>() {});
        } catch (Exception e) {
            return List.of(json.split(","));
        }
    }

    private String writeImagesJson(List<String> images) {
        if (images == null || images.isEmpty()) return null;
        try {
            return objectMapper.writeValueAsString(images);
        } catch (Exception e) {
            return String.join(",", images);
        }
    }

    private int calculateRelevanceScore(Product product, String keyword) {
        String name = product.getName() != null ? product.getName().toLowerCase(Locale.ROOT) : "";
        String brand = product.getBrand() != null ? product.getBrand().toLowerCase(Locale.ROOT) : "";
        String catName = (product.getCategory() != null && product.getCategory().getName() != null)
                ? product.getCategory().getName().toLowerCase(Locale.ROOT)
                : "";
        String desc = product.getDescription() != null ? product.getDescription().toLowerCase(Locale.ROOT) : "";

        if (name.equalsIgnoreCase(keyword)) return 0;
        if (name.startsWith(keyword)) return 1;
        if (name.contains(keyword)) return 2;
        if (brand.equalsIgnoreCase(keyword)) return 3;
        if (brand.contains(keyword)) return 4;
        if (catName.contains(keyword)) return 5;
        if (desc.contains(keyword)) return 6;
        return 10;
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
        String desc = product.getDescription() != null ? product.getDescription().toLowerCase(Locale.ROOT) : "";
        return name.contains(keyword) || brand.contains(keyword) || catName.contains(keyword) || desc.contains(keyword);
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
