package fu.ce191491.orderservice.entity;

import lombok.Getter;

@Getter
public enum OrderStatus {
    PENDING("Chờ xác nhận"),
    CONFIRMED("Đã xác nhận"),
    SHIPPING("Đang giao"),
    DELIVERED("Đã giao"),
    CANCELLED("Đã hủy");

    private final String description;

    OrderStatus(String description) {
        this.description = description;
    }

    public static OrderStatus fromString(String text) {
        if (text == null || text.isBlank() || "ALL".equalsIgnoreCase(text.trim())) {
            return null;
        }
        for (OrderStatus s : values()) {
            if (s.name().equalsIgnoreCase(text.trim()) || s.getDescription().equalsIgnoreCase(text.trim())) {
                return s;
            }
        }
        return null;
    }
}
