package fu.ce191491.orderservice.repository;

import fu.ce191491.orderservice.entity.Order;
import fu.ce191491.orderservice.entity.OrderStatus;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, String> {

    @EntityGraph(attributePaths = {"items"})
    Optional<Order> findWithItemsById(String id);

    @EntityGraph(attributePaths = {"items"})
    Optional<Order> findWithItemsByIdAndUserId(String id, String userId);

    @EntityGraph(attributePaths = {"items"})
    List<Order> findByUserIdOrderByCreatedAtDesc(String userId);

    @EntityGraph(attributePaths = {"items"})
    List<Order> findByUserIdAndStatusOrderByCreatedAtDesc(String userId, OrderStatus status);
}
