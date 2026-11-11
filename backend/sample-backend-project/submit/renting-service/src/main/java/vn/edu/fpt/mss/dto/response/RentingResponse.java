package vn.edu.fpt.mss.dto.response;

import java.math.BigDecimal;
import java.time.LocalDate;

public record RentingResponse(
    Integer rentingId,
    String customerId,
    Integer carId,
    String carName,
    String carModel,
    LocalDate rentStartDate,
    LocalDate rentEndDate,
    BigDecimal totalPrice
) {}
