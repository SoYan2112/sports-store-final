package fu.ce190984.identityservice.controller;

import fu.ce190984.identityservice.common.ApiResponse;
import fu.ce190984.identityservice.dto.ShippingAddressDTO;
import fu.ce190984.identityservice.dto.ShippingAddressRequest;
import fu.ce190984.identityservice.service.ShippingAddressService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/shipping-addresses")
@RequiredArgsConstructor
public class ShippingAddressController {
    private final ShippingAddressService service;

    @GetMapping
    public ResponseEntity<ApiResponse<List<ShippingAddressDTO>>> getAll(@RequestHeader(value = "Authorization", required = false) String auth) {
        return ResponseEntity.ok(ApiResponse.success("Lấy danh sách địa chỉ giao hàng thành công", service.getAll(auth)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ShippingAddressDTO>> getById(@RequestHeader(value = "Authorization", required = false) String auth, @PathVariable String id) {
        return ResponseEntity.ok(ApiResponse.success("Lấy địa chỉ giao hàng thành công", service.getById(auth, id)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ShippingAddressDTO>> create(@RequestHeader(value = "Authorization", required = false) String auth, @Valid @RequestBody ShippingAddressRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success("Tạo địa chỉ giao hàng thành công", service.create(auth, request)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<ShippingAddressDTO>> update(@RequestHeader(value = "Authorization", required = false) String auth, @PathVariable String id, @Valid @RequestBody ShippingAddressRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Cập nhật địa chỉ giao hàng thành công", service.update(auth, id, request)));
    }

    @PatchMapping("/{id}/default")
    public ResponseEntity<ApiResponse<ShippingAddressDTO>> setDefault(
            @RequestHeader(value = "Authorization", required = false) String auth,
            @PathVariable String id) {
        return ResponseEntity.ok(ApiResponse.success("Set default shipping address successfully", service.setDefault(auth, id)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@RequestHeader(value = "Authorization", required = false) String auth, @PathVariable String id) {
        service.delete(auth, id);
        return ResponseEntity.ok(ApiResponse.success("Xóa địa chỉ giao hàng thành công", null));
    }
}
