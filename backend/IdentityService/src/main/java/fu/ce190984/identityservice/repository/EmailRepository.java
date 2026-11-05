package fu.ce190984.identityservice.repository;

import fu.ce190984.identityservice.entity.Email;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface EmailRepository extends JpaRepository<Email, String> {
    Optional<Email> findByAddress(String address);
    boolean existsByAddress(String address);
}
