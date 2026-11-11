package vn.edu.fpt.mss.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "Renting")
public class Renting {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "RentingId")
    private Integer rentingId;

    @Column(name = "CustomerId", nullable = false, length = 50)
    private String customerId;

    @Column(name = "CarId", nullable = false)
    private Integer carId;

    @Column(name = "StartDate", nullable = false)
    private LocalDate rentStartDate;

    @Column(name = "EndDate", nullable = false)
    private LocalDate rentEndDate;

    @Column(name = "TotalPrice", nullable = false, precision = 18, scale = 2)
    private BigDecimal totalPrice;
}
