package fu.ce191491.voucherservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Yêu cầu kiểm tra và áp dụng mã voucher")
public class ApplyVoucherRequest {

    @Schema(description = "Mã voucher cần áp dụng (ví dụ: SUMMER20, FREESHIP...)", example = "SUMMER20")
    @NotBlank(message = "Mã voucher không được để trống")
    private String code;

    @Schema(description = "Giá trị tạm tính của đơn hàng (VNĐ)", example = "1000000")
    @NotNull(message = "Giá trị đơn hàng không được để trống")
    @DecimalMin(value = "0.0", message = "Giá trị đơn hàng phải lớn hơn hoặc bằng 0")
    private BigDecimal orderSubtotal;

    @Schema(description = "Phí vận chuyển (dùng để tính chiết khấu freeship, nếu có)", example = "30000")
    private BigDecimal shippingFee;
}

