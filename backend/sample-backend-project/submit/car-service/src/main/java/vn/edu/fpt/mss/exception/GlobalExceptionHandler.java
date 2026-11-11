package vn.edu.fpt.mss.exception;

import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.dao.TransientDataAccessException;
import org.springframework.orm.ObjectOptimisticLockingFailureException;
import org.springframework.transaction.CannotCreateTransactionException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ApiException.class)
    public ResponseEntity<Map<String, String>> business(ApiException ex) {
        return ResponseEntity.status(ex.getStatus()).body(Map.of("error", ex.getMessage()));
    }

    @ExceptionHandler({
        MethodArgumentNotValidException.class,
        HttpMessageNotReadableException.class,
        MethodArgumentTypeMismatchException.class,
        jakarta.validation.ConstraintViolationException.class,
        DataIntegrityViolationException.class,
    })
    public ResponseEntity<Map<String, String>> invalid(Exception ex) {
        return ResponseEntity.badRequest().body(Map.of("error", "Invalid data"));
    }
    @ExceptionHandler({
        org.springframework.dao.ConcurrencyFailureException.class,
        ObjectOptimisticLockingFailureException.class,
    })
    public ResponseEntity<Map<String, String>> conflict(Exception ex) {
        return ResponseEntity.status(409).body(Map.of("error", "Concurrent update; please retry"));
    }

    @ExceptionHandler({
        DataAccessResourceFailureException.class,
        TransientDataAccessException.class,
        CannotCreateTransactionException.class,
    })
    public ResponseEntity<Map<String, String>> unavailable(Exception ex) {
        log.error("Database unavailable", ex);
        return ResponseEntity.status(503).body(Map.of("error", "Database unavailable; please retry"));
    }

    @ExceptionHandler(org.springframework.web.ErrorResponseException.class)
    public ResponseEntity<Map<String, String>> httpError(org.springframework.web.ErrorResponseException ex) {
        return ResponseEntity.status(ex.getStatusCode()).headers(ex.getHeaders())
            .body(Map.of("error", ex.getBody().getTitle()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, String>> unexpected(Exception ex) {
        if (ex instanceof org.springframework.web.ErrorResponse error) {
            return ResponseEntity.status(error.getStatusCode()).headers(error.getHeaders())
                .body(Map.of("error", error.getBody().getTitle()));
        }
        log.error("Unexpected request failure", ex);
        return ResponseEntity.internalServerError().body(Map.of("error", "Internal server error"));
    }
}
