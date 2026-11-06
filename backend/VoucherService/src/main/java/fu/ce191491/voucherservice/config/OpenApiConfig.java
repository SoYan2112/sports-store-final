package fu.ce191491.voucherservice.config;

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
                        .title("VoucherService API - CE191491")
                        .version("1.0.0")
                        .description("Microservice Quản lý Khuyến mãi & Voucher cho Sports Store - Xem danh sách Voucher (UC-21)"));
    }
}

