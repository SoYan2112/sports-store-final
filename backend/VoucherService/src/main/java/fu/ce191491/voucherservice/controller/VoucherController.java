package fu.ce191491.voucherservice.controller;

import fu.ce191491.voucherservice.common.ApiResponse;
import fu.ce191491.voucherservice.dto.VoucherResponse;
import fu.ce191491.voucherservice.service.VoucherService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/vouchers")
@RequiredArgsConstructor
public class VoucherController {

    private final VoucherService voucherService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<VoucherResponse>>> getVouchers() {
        List<VoucherResponse> vouchers = voucherService.getAllActiveVouchers();
        return ResponseEntity.ok(ApiResponse.success("Lấy danh sách voucher thành công", vouchers));
    }

    @GetMapping("/{code}")
    public ResponseEntity<ApiResponse<VoucherResponse>> getVoucherByCode(
            @Parameter(description = "Mã voucher (ví dụ: SUMMER20, FREESHIP...)", required = true)
            @PathVariable("code") String code) {

        VoucherResponse voucher = voucherService.getVoucherByCode(code);
        return ResponseEntity.ok(ApiResponse.success("Lấy thông tin voucher thành công", voucher));
    }
}

