package vn.edu.fpt.mss;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import org.junit.jupiter.api.Test;
import org.springframework.dao.*;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.mss.exception.GlobalExceptionHandler;

class ExceptionHandlerTests {
    @RestController
    static class Failures {
        @GetMapping("/failure/{kind}")
        void fail(@PathVariable String kind) {
            switch (kind) {
                case "integrity" -> throw new DataIntegrityViolationException("secret SQL");
                case "lock" -> throw new CannotAcquireLockException("secret SQL");
                case "database" -> throw new DataAccessResourceFailureException("secret credentials");
                default -> throw new IllegalStateException("secret details");
            }
        }
    }

    @Test
    void errorsHaveAppropriateStatusAndSafeBody() throws Exception {
        MockMvc mvc = MockMvcBuilders.standaloneSetup(new Failures())
            .setControllerAdvice(new GlobalExceptionHandler()).build();
        String[] kinds = {"integrity", "lock", "database", "unexpected"};
        int[] statuses = {400, 409, 503, 500};
        String[] messages = {"Invalid data", "Concurrent update; please retry",
            "Database unavailable; please retry", "Internal server error"};
        for (int i = 0; i < kinds.length; i++) {
            mvc.perform(get("/failure/{kind}", kinds[i]))
                .andExpect(status().is(statuses[i]))
                .andExpect(content().json("{\"error\":\"" + messages[i] + "\"}"));
        }
        mvc.perform(post("/failure/integrity")).andExpect(status().isMethodNotAllowed());
    }
}
