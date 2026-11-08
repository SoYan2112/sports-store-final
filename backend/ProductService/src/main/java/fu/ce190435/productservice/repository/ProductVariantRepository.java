package fu.ce190435.productservice.repository;

import fu.ce190435.productservice.entity.ProductVariant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductVariantRepository extends JpaRepository<ProductVariant, String> {
    List<ProductVariant> findByProduct_Id(String productId);

    Optional<ProductVariant> findByProduct_IdAndSizeAndColorCode(String productId, String size, Long colorCode);
}

