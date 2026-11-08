package fu.ce190984.identityservice.service;

import fu.ce190984.identityservice.dto.ShippingAddressDTO;
import fu.ce190984.identityservice.dto.ShippingAddressRequest;
import java.util.List;

public interface ShippingAddressService {
    List<ShippingAddressDTO> getAll(String authHeader);
    ShippingAddressDTO getById(String authHeader, String id);
    ShippingAddressDTO create(String authHeader, ShippingAddressRequest request);
    ShippingAddressDTO update(String authHeader, String id, ShippingAddressRequest request);
    void delete(String authHeader, String id);
}
