package fu.ce190984.identityservice.service.impl;

import fu.ce190984.identityservice.common.ApiException;
import fu.ce190984.identityservice.dto.AuthResponse;
import fu.ce190984.identityservice.dto.LoginRequest;
import fu.ce190984.identityservice.dto.RegisterRequest;
import fu.ce190984.identityservice.dto.UserDTO;
import fu.ce190984.identityservice.entity.Email;
import fu.ce190984.identityservice.entity.User;
import fu.ce190984.identityservice.repository.EmailRepository;
import fu.ce190984.identityservice.repository.UserRepository;
import fu.ce190984.identityservice.security.JwtTokenProvider;
import fu.ce190984.identityservice.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final EmailRepository emailRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    @Override
    @Transactional
    public UserDTO register(RegisterRequest request) {
        String cleanEmail = request.getEmail().trim().toLowerCase();

        if (emailRepository.existsByAddress(cleanEmail) || userRepository.existsByUsername(cleanEmail)) {
            throw ApiException.conflict("Email này đã được sử dụng");
        }

        if (request.getPhoneNumber() != null && !request.getPhoneNumber().isBlank()) {
            String cleanPhone = request.getPhoneNumber().trim();
            if (userRepository.existsByPhoneNumber(cleanPhone)) {
                throw ApiException.conflict("Số điện thoại này đã được sử dụng");
            }
        }

        Email emailEntity = new Email(cleanEmail);

        User user = User.builder()
                .fullName(request.getFullname().trim())
                .username(cleanEmail)
                .password(passwordEncoder.encode(request.getPassword()))
                .phoneNumber(request.getPhoneNumber() != null ? request.getPhoneNumber().trim() : null)
                .status("ACTIVE")
                .gender(true)
                .email(emailEntity)
                .createdAt(System.currentTimeMillis())
                .build();

        emailEntity.setUser(user);
        User savedUser = userRepository.save(user);

        return toUserDTO(savedUser);
    }

    @Override
    @Transactional
    public AuthResponse login(LoginRequest request) {
        String identifier = request.getEmail().trim();

        User user = userRepository.findByEmailOrUsername(identifier)
                .orElseThrow(() -> ApiException.unauthorized("Tài khoản hoặc mật khẩu không chính xác"));

        if ("BANNED".equalsIgnoreCase(user.getStatus())) {
            throw ApiException.badRequest("Tài khoản của bạn đã bị khóa");
        }

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw ApiException.unauthorized("Tài khoản hoặc mật khẩu không chính xác");
        }

        String email = user.getEmail() != null ? user.getEmail().getAddress() : user.getUsername();
        String token = jwtTokenProvider.generateToken(user.getId(), email);
        user.setToken(token);
        userRepository.save(user);

        return AuthResponse.builder()
                .accessToken(token)
                .tokenType("Bearer")
                .user(toUserDTO(user))
                .build();
    }

    @Override
    @Transactional
    public void logout(String authHeader) {
        String token = extractToken(authHeader);
        if (token == null || token.isBlank()) {
            throw ApiException.badRequest("Không tìm thấy token đăng nhập");
        }

        jwtTokenProvider.blacklistToken(token);

        userRepository.findByToken(token).ifPresent(user -> {
            user.setToken(null);
            userRepository.save(user);
        });
    }

    @Override
    @Transactional(readOnly = true)
    public UserDTO getCurrentUser(String authHeader) {
        String token = extractToken(authHeader);
        if (token == null || token.isBlank() || !jwtTokenProvider.validateToken(token)) {
            throw ApiException.unauthorized("Chưa đăng nhập hoặc token không hợp lệ");
        }

        String email = jwtTokenProvider.getEmailFromToken(token);
        User user = userRepository.findByEmailOrUsername(email)
                .orElseThrow(() -> ApiException.unauthorized("Phiên đăng nhập không hợp lệ hoặc đã hết hạn"));

        return toUserDTO(user);
    }

    private String extractToken(String authHeader) {
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7).trim();
        }
        return authHeader;
    }

    private UserDTO toUserDTO(User user) {
        return UserDTO.builder()
                .id(user.getId())
                .fullname(user.getFullName())
                .email(user.getEmail() != null ? user.getEmail().getAddress() : user.getUsername())
                .phoneNumber(user.getPhoneNumber())
                .createdAt(user.getCreatedAt())
                .build();
    }
}
