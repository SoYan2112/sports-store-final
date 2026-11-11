package vn.edu.fpt.mss.dto.response;

import java.math.BigDecimal;

public record CarResponse(
    Integer carId,
    String carName,
    String model,
    String color,
    BigDecimal pricePerDay,
    String status
) {}
