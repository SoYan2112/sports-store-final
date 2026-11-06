package fu.ce191491.voucherservice.entity;

import lombok.Getter;

@Getter
public enum VoucherType {
    PERCENTAGE("percentage", "Giảm theo phần trăm"),
    FIXED_AMOUNT("fixed_amount", "Giảm tiền mặt trực tiếp"),
    FREE_SHIPPING("free_shipping", "Miễn phí vận chuyển");

    private final String code;
    private final String description;

    VoucherType(String code, String description) {
        this.code = code;
        this.description = description;
    }
}

