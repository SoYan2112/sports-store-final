package fu.ce190984.identityservice.controller;

import fu.ce190984.identityservice.common.ApiResponse;
import fu.ce190984.identityservice.dto.AuthResponse;
import fu.ce190984.identityservice.dto.LoginRequest;
import fu.ce190984.identityservice.dto.RegisterRequest;
import fu.ce190984.identityservice.dto.UserDTO;
import fu.ce190984.identityservice.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<UserDTO>> register(@Valid @RequestBody RegisterRequest request) {
        UserDTO result = authService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Đăng ký tài khoản thành công", result));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse result = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success("Đăng nhập thành công", result));
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(
            @RequestHeader(value = "Authorization", required = false) String authHeader) {
        authService.logout(authHeader);
        return ResponseEntity.ok(ApiResponse.success("Đăng xuất thành công", null));
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserDTO>> me(
            @RequestHeader(value = "Authorization", required = false) String authHeader) {
        UserDTO result = authService.getCurrentUser(authHeader);
        return ResponseEntity.ok(ApiResponse.success("Lấy thông tin tài khoản thành công", result));
    }
}
