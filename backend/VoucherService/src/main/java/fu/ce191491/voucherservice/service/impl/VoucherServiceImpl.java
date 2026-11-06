package fu.ce191491.voucherservice.service.impl;

import fu.ce191491.voucherservice.common.ApiException;
import fu.ce191491.voucherservice.dto.ApplyVoucherRequest;
import fu.ce191491.voucherservice.dto.ApplyVoucherResponse;
import fu.ce191491.voucherservice.dto.VoucherResponse;
import fu.ce191491.voucherservice.entity.Voucher;
import fu.ce191491.voucherservice.repository.VoucherRepository;
import fu.ce191491.voucherservice.service.VoucherService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
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

    @Override
    @Transactional(readOnly = true)
    public ApplyVoucherResponse applyVoucher(ApplyVoucherRequest request) {
        if (request == null || request.getCode() == null || request.getCode().isBlank()) {
            throw ApiException.badRequest("Mã voucher không được để trống");
        }
        if (request.getOrderSubtotal() == null || request.getOrderSubtotal().compareTo(BigDecimal.ZERO) < 0) {
            throw ApiException.badRequest("Giá trị đơn hàng không hợp lệ");
        }

        String code = request.getCode().trim();
        BigDecimal subtotal = request.getOrderSubtotal();
        BigDecimal shippingFee = request.getShippingFee() != null ? request.getShippingFee() : BigDecimal.ZERO;

        // 1. Tìm voucher theo mã và đang kích hoạt
        Voucher voucher = voucherRepository.findByCodeIgnoreCaseAndIsActiveTrue(code)
                .orElseThrow(() -> ApiException.notFound("Mã giảm giá '" + code + "' không tồn tại hoặc đã hết lượt sử dụng"));

        LocalDateTime now = LocalDateTime.now();

        // 2. Kiểm tra ngày bắt đầu
        if (voucher.getStartDate() != null && now.isBefore(voucher.getStartDate())) {
            throw ApiException.badRequest("Mã giảm giá '" + code + "' chưa đến thời gian áp dụng");
        }

        // 3. Kiểm tra ngày hết hạn
        if (voucher.getEndDate() != null && now.isAfter(voucher.getEndDate())) {
            throw ApiException.badRequest("Mã giảm giá '" + code + "' đã hết hạn sử dụng");
        }

        // 4. Kiểm tra giá trị đơn hàng tối thiểu
        if (voucher.getMinOrderValue() != null && subtotal.compareTo(voucher.getMinOrderValue()) < 0) {
            throw ApiException.badRequest(String.format("Đơn hàng chưa đạt giá trị tối thiểu %,.0f ₫ để áp dụng mã này",
                    voucher.getMinOrderValue()));
        }

        // 5. Tính toán số tiền được giảm giá
        BigDecimal discountAmount = BigDecimal.ZERO;

        switch (voucher.getType()) {
            case PERCENTAGE:
                BigDecimal percent = voucher.getDiscountValue().divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
                discountAmount = subtotal.multiply(percent).setScale(0, RoundingMode.HALF_UP);

                if (voucher.getMaxDiscountAmount() != null && discountAmount.compareTo(voucher.getMaxDiscountAmount()) > 0) {
                    discountAmount = voucher.getMaxDiscountAmount();
                }
                break;

            case FIXED_AMOUNT:
                discountAmount = voucher.getDiscountValue();
                if (discountAmount.compareTo(subtotal) > 0) {
                    discountAmount = subtotal;
                }
                break;

            case FREE_SHIPPING:
                discountAmount = voucher.getDiscountValue().min(shippingFee);
                break;
        }

        BigDecimal finalSubtotal = subtotal.subtract(discountAmount).max(BigDecimal.ZERO);

        return ApplyVoucherResponse.builder()
                .code(voucher.getCode())
                .title(voucher.getTitle())
                .type(voucher.getType().getCode())
                .discountAmount(discountAmount)
                .originalSubtotal(subtotal)
                .finalSubtotal(finalSubtotal)
                .message(String.format("Áp dụng mã giảm giá thành công! Bạn được giảm %,.0f ₫", discountAmount))
                .build();
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
