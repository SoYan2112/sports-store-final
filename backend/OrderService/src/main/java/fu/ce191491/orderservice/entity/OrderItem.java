package fu.ce191491.orderservice.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "order_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @Column(name = "product_id", nullable = false, length = 64)
    private String productId;

    @Column(name = "product_name", nullable = false)
    private String productName;

    private String brand;

    @Column(name = "image_url", length = 1000)
    private String imageUrl;

    @Column(name = "selected_size", length = 50)
    private String selectedSize;

    @Column(name = "selected_color")
    private Long selectedColor;

    @Column(name = "price", precision = 18, scale = 2, nullable = false)
    private BigDecimal price;

    @Column(name = "quantity", nullable = false)
    private Integer quantity;

    @Column(name = "item_total", precision = 18, scale = 2, nullable = false)
    private BigDecimal itemTotal;
}

