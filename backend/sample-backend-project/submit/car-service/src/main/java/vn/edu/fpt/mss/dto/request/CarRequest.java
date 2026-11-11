package vn.edu.fpt.mss.dto.request;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;

public record CarRequest(
    @NotBlank @Size(max = 100) String carName,
    @NotBlank @Size(max = 100) String model,
    @NotBlank @Size(max = 50) String color,
    @NotNull
    @DecimalMin(value = "0", inclusive = false)
    @Digits(integer = 16, fraction = 2)
    BigDecimal pricePerDay,
    @NotBlank @Pattern(regexp = "Available|Rented") String status
) {}
