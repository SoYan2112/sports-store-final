package fu.ce190984.identityservice.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ShippingAddressDTO {
    private String id;
    private String title;
    private String street;
    private String ward;
    private String province;
    private String country;
    private Long createdAt;
}
