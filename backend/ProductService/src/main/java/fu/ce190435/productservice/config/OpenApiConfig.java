package fu.ce190435.productservice.config;

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
                        .title("ProductService API")
                        .version("1.0.0")
                        .description("Microservice quản lý Danh mục, Sản phẩm và Biến thể kích cỡ/màu sắc"));
    }
}
