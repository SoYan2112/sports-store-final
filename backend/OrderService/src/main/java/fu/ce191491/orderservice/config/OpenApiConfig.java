package fu.ce191491.orderservice.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("OrderService API - CE191491")
                        .version("1.0.0")
                        .description("Microservice quản lý đơn hàng cho Sports Store - Xem chi tiết đơn hàng (UC-15)"));
    }
}

