package fu.ce190435.productservice.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "product_variants")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductVariant {

    @Id
    @Column(name = "variant_id", length = 100)
    private String id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "size", nullable = false, length = 20)
    private String size;

    @Column(name = "color_code", nullable = false)
    private Long colorCode;

    @Column(name = "color_name", columnDefinition = "NVARCHAR(100)")
    private String colorName;

    @Column(name = "stock", nullable = false)
    private Integer stock;

    @Column(name = "price")
    private Double price;
}

