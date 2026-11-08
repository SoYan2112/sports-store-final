package fu.ce190984.identityservice.service.impl;

import fu.ce190984.identityservice.common.ApiException;
import fu.ce190984.identityservice.dto.ShippingAddressDTO;
import fu.ce190984.identityservice.dto.ShippingAddressRequest;
import fu.ce190984.identityservice.entity.ShippingAddress;
import fu.ce190984.identityservice.entity.User;
import fu.ce190984.identityservice.repository.ShippingAddressRepository;
import fu.ce190984.identityservice.repository.UserRepository;
import fu.ce190984.identityservice.service.ShippingAddressService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ShippingAddressServiceImpl implements ShippingAddressService {
    private final ShippingAddressRepository addressRepository;
    private final UserRepository userRepository;

    @Override @Transactional(readOnly = true)
    public List<ShippingAddressDTO> getAll(String authHeader) {
        User user = currentUser(authHeader);
        return addressRepository.findAllByUserId(user.getId()).stream().map(this::toDto).toList();
    }

    @Override @Transactional(readOnly = true)
    public ShippingAddressDTO getById(String authHeader, String id) {
        return toDto(findOwned(authHeader, id));
    }

    @Override @Transactional
    public ShippingAddressDTO create(String authHeader, ShippingAddressRequest request) {
        ShippingAddress address = fromRequest(request);
        address.setUser(currentUser(authHeader));
        address.setCreatedAt(System.currentTimeMillis());
        return toDto(addressRepository.save(address));
    }

    @Override @Transactional
    public ShippingAddressDTO update(String authHeader, String id, ShippingAddressRequest request) {
        ShippingAddress address = findOwned(authHeader, id);
        copy(request, address);
        return toDto(addressRepository.save(address));
    }

    @Override @Transactional
    public void delete(String authHeader, String id) {
        addressRepository.delete(findOwned(authHeader, id));
    }

    private User currentUser(String authHeader) {
        String token = authHeader != null && authHeader.startsWith("Bearer ")
                ? authHeader.substring(7).trim() : authHeader;
        if (token == null || token.isBlank()) throw ApiException.unauthorized("Chưa đăng nhập");
        return userRepository.findByToken(token)
                .orElseThrow(() -> ApiException.unauthorized("Phiên đăng nhập không hợp lệ hoặc đã hết hạn"));
    }

    private ShippingAddress findOwned(String authHeader, String id) {
        User user = currentUser(authHeader);
        return addressRepository.findByIdAndUserId(id, user.getId())
                .orElseThrow(() -> ApiException.badRequest("Không tìm thấy địa chỉ giao hàng"));
    }

    private ShippingAddress fromRequest(ShippingAddressRequest r) {
        ShippingAddress a = new ShippingAddress(); copy(r, a); return a;
    }

    private void copy(ShippingAddressRequest r, ShippingAddress a) {
        a.setTitle(r.getTitle().trim()); a.setStreet(r.getStreet().trim());
        a.setWard(r.getWard().trim()); a.setProvince(r.getProvince().trim());
        a.setCountry(r.getCountry().trim());
    }

    private ShippingAddressDTO toDto(ShippingAddress a) {
        return ShippingAddressDTO.builder().id(a.getId()).title(a.getTitle()).street(a.getStreet())
                .ward(a.getWard()).province(a.getProvince()).country(a.getCountry()).createdAt(a.getCreatedAt()).build();
    }
}
