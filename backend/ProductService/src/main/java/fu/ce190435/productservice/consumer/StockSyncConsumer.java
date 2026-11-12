package fu.ce190435.productservice.consumer;

import fu.ce190435.productservice.config.RabbitMQConfig;
import fu.ce190435.productservice.dto.event.StockSyncEvent;
import fu.ce190435.productservice.service.ProductService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class StockSyncConsumer {

    private final ProductService productService;

    @RabbitListener(queues = RabbitMQConfig.QUEUE)
    public void handleStockSync(StockSyncEvent event) {
        if (event == null || event.getProductId() == null || event.getProductId().isBlank()) {
            log.warn("Ignored invalid StockSyncEvent: {}", event);
            return;
        }

        int qty = event.getQuantity() != null && event.getQuantity() > 0 ? event.getQuantity() : 1;
        String action = event.isRestore() ? "RESTORE" : "REDUCE";

        log.info("Processing asynchronous StockSyncEvent [{}]: orderId={}, productId={}, qty={}, size={}, colorCode={}",
                action, event.getOrderId(), event.getProductId(), qty, event.getSize(), event.getColorCode());

        try {
            if (event.isRestore()) {
                productService.restoreStock(event.getProductId(), qty, event.getSize(), event.getColorCode());
            } else {
                productService.reduceStock(event.getProductId(), qty, event.getSize(), event.getColorCode());
            }
            log.info("StockSyncEvent [{}] completed successfully for productId={}", action, event.getProductId());
        } catch (Exception ex) {
            log.error("Failed to process StockSyncEvent [{}]: {}", action, ex.getMessage(), ex);
        }
    }
}
