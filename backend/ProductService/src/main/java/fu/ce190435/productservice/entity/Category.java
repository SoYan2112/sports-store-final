package fu.ce190435.productservice.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "categories")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Category {

    @Id
    @Column(name = "category_id", length = 64)
    private String id;

    @Column(name = "name", nullable = false, columnDefinition = "NVARCHAR(255)")
    private String name;

    @Column(name = "image_url", length = 550)
    private String imageUrl;

    @Column(name = "description", columnDefinition = "NVARCHAR(500)")
    private String description;

    @Column(name = "item_count")
    private Integer itemCount;
}

