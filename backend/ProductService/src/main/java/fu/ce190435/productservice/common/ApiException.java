package fu.ce190435.productservice.common;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public class ApiException extends RuntimeException {
    private final HttpStatus httpStatus;
    private final int status;

    public ApiException(HttpStatus httpStatus, int status, String message) {
        super(message);
        this.httpStatus = httpStatus;
        this.status = status;
    }

    public static ApiException badRequest(String message) {
        return new ApiException(HttpStatus.BAD_REQUEST, 2, message);
    }

    public static ApiException notFound(String message) {
        return new ApiException(HttpStatus.NOT_FOUND, 4, message);
    }

    public static ApiException conflict(String message) {
        return new ApiException(HttpStatus.CONFLICT, 5, message);
    }
}

