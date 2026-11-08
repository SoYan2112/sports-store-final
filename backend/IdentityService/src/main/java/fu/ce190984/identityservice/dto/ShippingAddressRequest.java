package fu.ce190984.identityservice.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ShippingAddressRequest {
    @NotBlank private String title;
    @NotBlank private String street;
    @NotBlank private String ward;
    @NotBlank private String province;
    @NotBlank private String country;
}
