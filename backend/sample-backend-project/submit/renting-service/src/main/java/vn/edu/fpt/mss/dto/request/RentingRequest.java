package vn.edu.fpt.mss.dto.request;

import jakarta.validation.constraints.*;
import java.time.LocalDate;

public record RentingRequest(
    @NotBlank @Size(max = 50) String customerId,
    @NotNull @Positive Integer carId,
    @NotNull LocalDate rentStartDate,
    @NotNull LocalDate rentEndDate
) {}
