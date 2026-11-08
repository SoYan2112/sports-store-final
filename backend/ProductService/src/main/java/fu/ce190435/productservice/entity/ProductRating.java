package fu.ce190435.productservice.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "product_ratings")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductRating {

    @Id
    @Column(name = "rating_id", length = 64)
    private String id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "user_id", nullable = false, length = 64)
    private String userId;

    @Column(name = "user_name", nullable = false, columnDefinition = "NVARCHAR(100)")
    private String userName;

    @Column(name = "user_avatar", length = 550)
    private String userAvatar;

    @Column(name = "rating", nullable = false)
    private Integer rating;

    @Column(name = "comment", columnDefinition = "NVARCHAR(MAX)")
    private String comment;

    @Column(name = "size_bought", length = 20)
    private String sizeBought;

    @Column(name = "color_bought", columnDefinition = "NVARCHAR(100)")
    private String colorBought;

    @Column(name = "images_json", columnDefinition = "NVARCHAR(MAX)")
    private String imagesJson;

    @Column(name = "created_at", nullable = false)
    private Long createdAt;
}
