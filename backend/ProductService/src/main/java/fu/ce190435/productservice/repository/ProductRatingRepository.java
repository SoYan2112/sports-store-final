package fu.ce190435.productservice.repository;

import fu.ce190435.productservice.entity.ProductRating;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductRatingRepository extends JpaRepository<ProductRating, String> {
    List<ProductRating> findByProduct_Id(String productId);

    List<ProductRating> findByProduct_IdAndRating(String productId, Integer rating);

    long countByProduct_Id(String productId);
}
