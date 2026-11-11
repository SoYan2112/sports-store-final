package vn.edu.fpt.mss.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "Car")
public class Car {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "CarId")
    private Integer carId;

    @Column(name = "CarName", nullable = false, length = 100)
    private String carName;

    @Column(name = "Model", nullable = false, length = 100)
    private String model;

    @Column(name = "Color", nullable = false, length = 50)
    private String color;

    @Column(name = "PricePerDay", nullable = false, precision = 18, scale = 2)
    private BigDecimal pricePerDay;

    @Column(name = "Status", nullable = false, length = 20)
    private String status;
}
