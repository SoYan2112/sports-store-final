package fu.ce190984.identityservice.service;

import fu.ce190984.identityservice.dto.AuthResponse;
import fu.ce190984.identityservice.dto.LoginRequest;
import fu.ce190984.identityservice.dto.RegisterRequest;
import fu.ce190984.identityservice.dto.UserDTO;

public interface AuthService {

    UserDTO register(RegisterRequest request);

    AuthResponse login(LoginRequest request);

    void logout(String authHeader);

    UserDTO getCurrentUser(String authHeader);
}
