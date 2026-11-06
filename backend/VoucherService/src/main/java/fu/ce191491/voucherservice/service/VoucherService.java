package fu.ce191491.voucherservice.service;

import fu.ce191491.voucherservice.dto.VoucherResponse;

import java.util.List;

public interface VoucherService {
    List<VoucherResponse> getAllActiveVouchers();

    VoucherResponse getVoucherByCode(String code);
}

