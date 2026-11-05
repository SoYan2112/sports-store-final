package fu.ce190984.identityservice.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "email")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Email {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "email_id")
    private String id;

    @Column(unique = true, nullable = false)
    private String address;

    @Column(name = "is_verified")
    private boolean isVerified;

    @Column(name = "code", length = 150)
    private String code;

    @Column(name = "verified_at")
    private Long verifiedAt;

    @Column(name = "created_at")
    private Long createdAt;

    @OneToOne(mappedBy = "email")
    @JsonIgnore
    private User user;

    public Email(String address) {
        this.address = address;
        this.isVerified = true;
        this.createdAt = System.currentTimeMillis();
    }
}
