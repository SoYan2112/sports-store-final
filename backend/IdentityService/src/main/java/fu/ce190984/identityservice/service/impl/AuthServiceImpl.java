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
import fu.ce190984.identityservice.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final EmailRepository emailRepository;

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
                .password(hashPassword(request.getPassword()))
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

        String hashedInputPassword = hashPassword(request.getPassword());
        boolean passwordMatches = hashedInputPassword.equalsIgnoreCase(user.getPassword())
                || request.getPassword().equals(user.getPassword());

        if (!passwordMatches) {
            throw ApiException.unauthorized("Tài khoản hoặc mật khẩu không chính xác");
        }

        String token = UUID.randomUUID().toString();
        user.setToken(token);
        userRepository.save(user);

        return AuthResponse.builder()
                .accessToken(token)
                .tokenType("Bearer")
                .user(toUserDTO(user))
                .build();
    }

    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] messageDigest = md.digest(password.getBytes());
            BigInteger no = new BigInteger(1, messageDigest);
            StringBuilder hashtext = new StringBuilder(no.toString(16));
            while (hashtext.length() < 32) {
                hashtext.insert(0, "0");
            }
            return hashtext.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password", e);
        }
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
