package vn.edu.fpt.mss.repository;

import jakarta.persistence.LockModeType;
import java.util.Optional;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;
import vn.edu.fpt.mss.entity.Car;

public interface CarRepository extends JpaRepository<Car, Integer> {
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select c from Car c where c.carId = :id")
    Optional<Car> findLockedById(@Param("id") Integer id);
}
