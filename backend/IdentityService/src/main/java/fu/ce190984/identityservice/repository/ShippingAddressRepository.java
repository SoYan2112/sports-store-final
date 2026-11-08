package fu.ce190984.identityservice.repository;

import fu.ce190984.identityservice.entity.ShippingAddress;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface ShippingAddressRepository extends JpaRepository<ShippingAddress, String> {
    List<ShippingAddress> findAllByUserId(String userId);
    Optional<ShippingAddress> findByIdAndUserId(String id, String userId);
}
