package fu.ce190435.productservice.dto.event;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StockSyncEvent implements Serializable {
    private String orderId;
    private String productId;
    private Integer quantity;
    private String size;
    private Long colorCode;
    private boolean restore;
}
