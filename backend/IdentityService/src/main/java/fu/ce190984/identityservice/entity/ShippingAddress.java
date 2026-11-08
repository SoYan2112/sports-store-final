package fu.ce190984.identityservice.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "shipping_address")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ShippingAddress {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    private String title;
    private String street;
    private String ward;
    private String province;
    private String country;

    @Column(name = "created_at", nullable = false)
    private Long createdAt;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
}
