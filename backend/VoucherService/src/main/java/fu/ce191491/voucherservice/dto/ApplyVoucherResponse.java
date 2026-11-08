package fu.ce191491.voucherservice.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Kết quả sau khi áp dụng voucher thành công")
public class ApplyVoucherResponse {

    @Schema(description = "Mã voucher đã áp dụng", example = "SUMMER20")
    private String code;

    @Schema(description = "Tiêu đề ưu đãi", example = "Giảm 20% đơn từ 400k")
    private String title;

    @Schema(description = "Loại voucher (percentage, fixed_amount, free_shipping)", example = "percentage")
    private String type;

    @Schema(description = "Số tiền được giảm giá (VNĐ)", example = "100000.00")
    private BigDecimal discountAmount;

    @Schema(description = "Giá trị đơn hàng ban đầu (VNĐ)", example = "1000000.00")
    private BigDecimal originalSubtotal;

    @Schema(description = "Giá trị sau khi áp dụng giảm giá (VNĐ)", example = "900000.00")
    private BigDecimal finalSubtotal;

    @Schema(description = "Thông báo kết quả", example = "Áp dụng mã giảm giá thành công! Giảm 100.000 ₫")
    private String message;
}

