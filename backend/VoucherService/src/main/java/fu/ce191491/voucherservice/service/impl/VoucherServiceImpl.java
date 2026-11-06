package fu.ce191491.voucherservice.service.impl;

import fu.ce191491.voucherservice.common.ApiException;
import fu.ce191491.voucherservice.dto.VoucherResponse;
import fu.ce191491.voucherservice.entity.Voucher;
import fu.ce191491.voucherservice.repository.VoucherRepository;
import fu.ce191491.voucherservice.service.VoucherService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class VoucherServiceImpl implements VoucherService {

    private final VoucherRepository voucherRepository;

    @Override
    @Transactional(readOnly = true)
    public List<VoucherResponse> getAllActiveVouchers() {
        List<Voucher> vouchers = voucherRepository.findByIsActiveTrueOrderByCreatedAtDesc();
        return vouchers.stream()
                .map(this::mapToVoucherResponse)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public VoucherResponse getVoucherByCode(String code) {
        if (code == null || code.isBlank()) {
            throw ApiException.badRequest("Mã voucher không được để trống");
        }

        Voucher voucher = voucherRepository.findByCodeIgnoreCaseAndIsActiveTrue(code.trim())
                .orElseThrow(() -> ApiException.notFound("Không tìm thấy voucher hợp lệ với mã: " + code));

        return mapToVoucherResponse(voucher);
    }

    private VoucherResponse mapToVoucherResponse(Voucher voucher) {
        return VoucherResponse.builder()
                .id(voucher.getId())
                .code(voucher.getCode())
                .title(voucher.getTitle())
                .description(voucher.getDescription())
                .type(voucher.getType() != null ? voucher.getType().getCode() : "fixed_amount")
                .discountValue(voucher.getDiscountValue())
                .minOrderValue(voucher.getMinOrderValue())
                .maxDiscountAmount(voucher.getMaxDiscountAmount())
                .startDate(voucher.getStartDate())
                .endDate(voucher.getEndDate())
                .isUsed(false)
                .build();
    }
}

