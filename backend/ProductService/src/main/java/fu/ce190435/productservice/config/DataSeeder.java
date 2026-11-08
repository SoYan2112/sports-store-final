package fu.ce190435.productservice.config;

import fu.ce190435.productservice.entity.Category;
import fu.ce190435.productservice.entity.Product;
import fu.ce190435.productservice.entity.ProductRating;
import fu.ce190435.productservice.entity.ProductVariant;
import fu.ce190435.productservice.repository.CategoryRepository;
import fu.ce190435.productservice.repository.ProductRatingRepository;
import fu.ce190435.productservice.repository.ProductRepository;
import fu.ce190435.productservice.repository.ProductVariantRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

        private final CategoryRepository categoryRepository;
        private final ProductRepository productRepository;
        private final ProductVariantRepository productVariantRepository;
        private final ProductRatingRepository productRatingRepository;

        @Override
        public void run(String... args) {
                if (categoryRepository.count() == 0) {
                        seedCategoriesAndProducts();
                }
                if (productVariantRepository.count() == 0) {
                        seedProductVariants();
                }
                if (productRatingRepository.count() == 0) {
                        seedProductRatings();
                }
        }

        private void seedCategoriesAndProducts() {
                Category shoes = Category.builder()
                                .id("cat_shoes")
                                .name("Giày thể thao")
                                .imageUrl("https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=700&auto=format&fit=crop&q=80")
                                .description("Giày chạy bộ, bóng rổ, training trợ lực đỉnh cao.")
                                .itemCount(8)
                                .build();

                Category tops = Category.builder()
                                .id("cat_tops")
                                .name("Áo thể thao")
                                .imageUrl("https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=700&auto=format&fit=crop&q=80")
                                .description("Áo thun thoáng khí, áo khoác gió, áo thi đấu chính hãng.")
                                .itemCount(3)
                                .build();

                Category bottoms = Category.builder()
                                .id("cat_bottoms")
                                .name("Quần thể thao")
                                .imageUrl("https://images.unsplash.com/photo-1517438476312-10d79c077509?w=700&auto=format&fit=crop&q=80")
                                .description("Quần shorts chạy bộ, quần jogger co giãn 4 chiều.")
                                .itemCount(2)
                                .build();

                Category accessories = Category.builder()
                                .id("cat_accessories")
                                .name("Phụ kiện thể thao")
                                .imageUrl("https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=700&auto=format&fit=crop&q=80")
                                .description("Balo chống nước, tất khử mùi, mũ lưỡi trai và bình nước.")
                                .itemCount(2)
                                .build();

                Category gear = Category.builder()
                                .id("cat_gear")
                                .name("Dụng cụ tập luyện")
                                .imageUrl("https://images.unsplash.com/photo-1518611012118-696072aa579a?w=700&auto=format&fit=crop&q=80")
                                .description("Thảm yoga bám sàn, dây kháng lực, tạ tay và băng quấn.")
                                .itemCount(2)
                                .build();

                Category protection = Category.builder()
                                .id("cat_protection")
                                .name("Đồ bảo hộ & Hỗ trợ")
                                .imageUrl("https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=700&auto=format&fit=crop&q=80")
                                .description("Băng bảo vệ khớp gối, cổ tay, mắt cá hạn chế chấn thương.")
                                .itemCount(2)
                                .build();

                categoryRepository.saveAll(List.of(shoes, tops, bottoms, accessories, gear, protection));

                long now = System.currentTimeMillis();
                List<Product> products = List.of(
                                Product.builder()
                                                .id("p1")
                                                .name("Nike unveil joyride")
                                                .brand("Nike")
                                                .price(1950000.0)
                                                .originalPrice(2450000.0)
                                                .imageUrl("https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&auto=format&fit=crop&q=80")
                                                .badge("Hot")
                                                .rating(4.9)
                                                .reviewCount(128)
                                                .description("Giày chạy bộ cao cấp với hạt đệm Joyride êm ái, trợ lực tối đa.")
                                                .stock(15)
                                                .category(shoes)
                                                .createdAt(now)
                                                .build(),
                                Product.builder()
                                                .id("p2")
                                                .name("React Infinity Run Flyknit")
                                                .brand("Nike")
                                                .price(2350000.0)
                                                .originalPrice(2800000.0)
                                                .imageUrl("https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=600&auto=format&fit=crop&q=80")
                                                .badge("New")
                                                .rating(4.8)
                                                .reviewCount(95)
                                                .description("Thiết kế giúp hạn chế chấn thương, đệm React êm ái và bám đường.")
                                                .stock(18)
                                                .category(shoes)
                                                .createdAt(now)
                                                .build(),
                                Product.builder()
                                                .id("p3")
                                                .name("Nike Dunk High Retro")
                                                .brand("Nike")
                                                .price(2990000.0)
                                                .originalPrice(null)
                                                .imageUrl("https://images.unsplash.com/photo-1552346154-21d32810aba3?w=600&auto=format&fit=crop&q=80")
                                                .badge("Best Seller")
                                                .rating(5.0)
                                                .reviewCount(210)
                                                .description("Phong cách bóng rổ cổ điển những năm 80, thiết kế cổ cao sành điệu.")
                                                .stock(12)
                                                .category(shoes)
                                                .createdAt(now)
                                                .build(),
                                Product.builder()
                                                .id("p4")
                                                .name("Adidas Ultraboost Light")
                                                .brand("Adidas")
                                                .price(3200000.0)
                                                .originalPrice(4200000.0)
                                                .imageUrl("https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=600&auto=format&fit=crop&q=80")
                                                .badge("Sale -24%")
                                                .rating(4.9)
                                                .reviewCount(164)
                                                .description("Đệm Light BOOST nhẹ nhất từ trước đến nay, hoàn trả năng lượng vượt trội.")
                                                .stock(14)
                                                .category(shoes)
                                                .createdAt(now)
                                                .build(),
                                Product.builder()
                                                .id("p5")
                                                .name("Puma Velocity Nitro 2")
                                                .brand("Puma")
                                                .price(1850000.0)
                                                .originalPrice(2200000.0)
                                                .imageUrl("https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=600&auto=format&fit=crop&q=80")
                                                .badge("New")
                                                .rating(4.7)
                                                .reviewCount(42)
                                                .description("Đệm bọt Nitro siêu nhạy và đế ngoài Pumagrip bám mọi bề mặt.")
                                                .stock(20)
                                                .category(shoes)
                                                .createdAt(now)
                                                .build(),
                                Product.builder()
                                                .id("p6")
                                                .name("Under Armour HOVR Phantom 3")
                                                .brand("Under Armour")
                                                .price(2650000.0)
                                                .originalPrice(null)
                                                .imageUrl("https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600&auto=format&fit=crop&q=80")
                                                .badge("Hot")
                                                .rating(4.8)
                                                .reviewCount(88)
                                                .description("Công nghệ UA HOVR giảm lực va chạm, đàn hồi năng lượng trên từng bước chạy.")
                                                .stock(10)
                                                .category(shoes)
                                                .createdAt(now)
                                                .build(),
                                Product.builder()
                                                .id("p7")
                                                .name("Reebok Club C 85 Vintage")
                                                .brand("Reebok")
                                                .price(1450000.0)
                                                .originalPrice(1900000.0)
                                                .imageUrl("https://images.unsplash.com/photo-1515955656352-a1fa3ffcd111?w=600&auto=format&fit=crop&q=80")
                                                .badge("Sale -23%")
                                                .rating(4.6)
                                                .reviewCount(75)
                                                .description("Phong cách quần vợt cổ điển với da mềm mại và đế lót êm ái.")
                                                .stock(16)
                                                .category(shoes)
                                                .createdAt(now)
                                                .build(),
                                Product.builder()
                                                .id("p8")
                                                .name("Nike Air Zoom Pegasus 40")
                                                .brand("Nike")
                                                .price(2790000.0)
                                                .originalPrice(3200000.0)
                                                .imageUrl("https://images.unsplash.com/photo-1575537302964-96cd47c06b1b?w=600&auto=format&fit=crop&q=80")
                                                .badge("Best Seller")
                                                .rating(4.9)
                                                .reviewCount(320)
                                                .description("Biểu tượng chạy bộ 40 năm với túi khí đôi Zoom Air trước và sau.")
                                                .stock(22)
                                                .category(shoes)
                                                .createdAt(now)
                                                .build(),
                                Product.builder()
                                                .id("p_top_1")
                                                .name("Áo thun chạy bộ Nike Dri-FIT")
                                                .brand("Nike")
                                                .price(650000.0)
                                                .originalPrice(850000.0)
                                                .imageUrl("https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=600&auto=format&fit=crop&q=80")
                                                .badge("Best Seller")
                                                .rating(4.8)
                                                .reviewCount(145)
                                                .description("Vải Dri-FIT siêu nhẹ, thấm hút mồ hôi và thoáng khí tối ưu.")
                                                .stock(25)
                                                .category(tops)
                                                .createdAt(now)
                                                .build(),
                                Product.builder()
                                                .id("p_top_2")
                                                .name("Áo khoác gió Adidas Tiro Track")
                                                .brand("Adidas")
                                                .price(1450000.0)
                                                .originalPrice(1800000.0)
                                                .imageUrl("https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=600&auto=format&fit=crop&q=80")
                                                .badge("Hot")
                                                .rating(4.9)
                                                .reviewCount(89)
                                                .description("Chất liệu chắn gió cản nước nhẹ nhàng, 3 sọc thể thao kinh điển.")
                                                .stock(15)
                                                .category(tops)
                                                .createdAt(now)
                                                .build(),
                                Product.builder()
                                                .id("p_bot_1")
                                                .name("Quần shorts chạy bộ 2-in-1 Pro")
                                                .brand("Nike")
                                                .price(790000.0)
                                                .originalPrice(950000.0)
                                                .imageUrl("https://images.unsplash.com/photo-1517438476312-10d79c077509?w=600&auto=format&fit=crop&q=80")
                                                .badge("Hot")
                                                .rating(4.8)
                                                .reviewCount(112)
                                                .description("Có lớp bó cơ bên trong chống cọ xát và túi đựng điện thoại tiện ích.")
                                                .stock(19)
                                                .category(bottoms)
                                                .createdAt(now)
                                                .build(),
                                Product.builder()
                                                .id("p_acc_1")
                                                .name("Balo thể thao chống nước đa năng")
                                                .brand("Nike")
                                                .price(890000.0)
                                                .originalPrice(1100000.0)
                                                .imageUrl("https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600&auto=format&fit=crop&q=80")
                                                .badge("Hot")
                                                .rating(4.9)
                                                .reviewCount(78)
                                                .description("Có ngăn riêng biệt đựng giày và laptop, chống nước bề mặt.")
                                                .stock(14)
                                                .category(accessories)
                                                .createdAt(now)
                                                .build());

                productRepository.saveAll(products);
        }

        private void seedProductVariants() {
                List<Product> products = productRepository.findAll();
                List<String> sizes = List.of("38", "39", "40", "41", "42", "43");
                Map<Long, String> colorMap = Map.of(
                                0xFF1A1A1AL, "Đen thể thao",
                                0xFFFFFFFFL, "Trắng tinh tế",
                                0xFFFF6B00L, "Cam năng động",
                                0xFF1E88E5L, "Xanh dương");

                List<ProductVariant> variants = new ArrayList<>();
                for (Product product : products) {
                        for (String size : sizes) {
                                for (Map.Entry<Long, String> colorEntry : colorMap.entrySet()) {
                                        Long colorCode = colorEntry.getKey();
                                        String variantId = product.getId() + "_" + size + "_" + colorCode;
                                        variants.add(ProductVariant.builder()
                                                        .id(variantId)
                                                        .product(product)
                                                        .size(size)
                                                        .colorCode(colorCode)
                                                        .colorName(colorEntry.getValue())
                                                        .stock(product.getStock() != null ? product.getStock() : 12)
                                                        .price(product.getPrice())
                                                        .build());
                                }
                        }
                }
                productVariantRepository.saveAll(variants);
        }

        private void seedProductRatings() {
                productRepository.findById("p1").ifPresent(p1 -> {
                        long now = System.currentTimeMillis();
                        List<ProductRating> ratings = List.of(
                                ProductRating.builder()
                                        .id("rev_p1_01")
                                        .product(p1)
                                        .userId("user_01")
                                        .userName("Hoàng Nhật")
                                        .userAvatar("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100")
                                        .rating(5)
                                        .comment("Giày chạy rất êm chân, trợ lực đệm hạt Joyride siêu nảy, đi tập 10km không hề mỏi!")
                                        .sizeBought("41")
                                        .colorBought("Đen thể thao")
                                        .imagesJson("[\"https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600\"]")
                                        .createdAt(now - 86400000L * 3)
                                        .build(),
                                ProductRating.builder()
                                        .id("rev_p1_02")
                                        .product(p1)
                                        .userId("user_02")
                                        .userName("San Yo")
                                        .userAvatar("https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=100")
                                        .rating(5)
                                        .comment("Hàng chuẩn chỉ, form giày chuẩn size, bám đường tốt trên cả mặt sàn ướt.")
                                        .sizeBought("42")
                                        .colorBought("Cam năng động")
                                        .imagesJson("[]")
                                        .createdAt(now - 86400000L * 2)
                                        .build(),
                                ProductRating.builder()
                                        .id("rev_p1_03")
                                        .product(p1)
                                        .userId("user_03")
                                        .userName("Minh Khang")
                                        .userAvatar("https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100")
                                        .rating(4)
                                        .comment("Chất lượng hoàn thiện tốt, đóng gói cẩn thận. Giao hàng nhanh 2 ngày là nhận được.")
                                        .sizeBought("40")
                                        .colorBought("Trắng tinh tế")
                                        .imagesJson("[]")
                                        .createdAt(now - 86400000L)
                                        .build()
                        );
                        productRatingRepository.saveAll(ratings);
                });
        }
}
