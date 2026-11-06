package fu.ce191491.voucherservice.repository;

import fu.ce191491.voucherservice.entity.Voucher;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VoucherRepository extends JpaRepository<Voucher, String> {

    List<Voucher> findByIsActiveTrueOrderByCreatedAtDesc();

    Optional<Voucher> findByCodeIgnoreCaseAndIsActiveTrue(String code);
}

