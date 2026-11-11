package vn.edu.fpt.mss.dto.client;

import java.math.BigDecimal;

public record CarInfo(
    Integer carId,
    String carName,
    String model,
    String color,
    BigDecimal pricePerDay,
    String status
) {}
