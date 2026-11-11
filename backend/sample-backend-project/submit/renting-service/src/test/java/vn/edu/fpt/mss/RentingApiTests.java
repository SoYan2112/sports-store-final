package vn.edu.fpt.mss;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.atomic.AtomicInteger;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import vn.edu.fpt.mss.repository.RentingRepository;

@SpringBootTest(
    properties = {
        "spring.datasource.url=jdbc:h2:mem:rentings;MODE=MSSQLServer;DB_CLOSE_DELAY=-1",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.jpa.hibernate.ddl-auto=create-drop",
    }
)
@AutoConfigureMockMvc
class RentingApiTests {

    static HttpServer carServer;
    static AtomicInteger mode = new AtomicInteger(200),
        gets = new AtomicInteger(),
        reserves = new AtomicInteger();

    @DynamicPropertySource
    static void carUrl(DynamicPropertyRegistry properties) throws IOException {
        carServer = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        carServer.createContext("/", exchange -> {
            boolean reserve = exchange.getRequestURI().getPath().startsWith("/internal/");
            if (reserve) reserves.incrementAndGet();
            else gets.incrementAndGet();
            int status = mode.get();
            if (status == 208) status = 200;
            String state = mode.get() == 208 || reserve ? "Rented" : "Available";
            String body =
                status == 200
                    ? "{\"carId\":1,\"carName\":\"Toyota Camry\",\"model\":\"Camry 2.5Q\",\"color\":\"Black\",\"pricePerDay\":1500000,\"status\":\"" +
                      state +
                      "\"}"
                    : "{\"error\":\"test\"}";
            byte[] bytes = body.getBytes(StandardCharsets.UTF_8);
            exchange.getResponseHeaders().set("Content-Type", "application/json");
            exchange.sendResponseHeaders(status, bytes.length);
            exchange.getResponseBody().write(bytes);
            exchange.close();
        });
        carServer.start();
        properties.add(
            "services.car-url",
            () -> "http://127.0.0.1:" + carServer.getAddress().getPort()
        );
    }

    @AfterAll
    static void stop() {
        carServer.stop(0);
    }

    @Autowired
    MockMvc mvc;

    @Autowired
    RentingRepository repository;

    @BeforeEach
    void reset() {
        repository.deleteAll();
        mode.set(200);
        gets.set(0);
        reserves.set(0);
    }

    private String request() {
        return """
        {"customerId":"CUST-001","carId":1,"rentStartDate":"2026-10-15","rentEndDate":"2026-10-17"}
        """;
    }

    @Test
    void createAndListUseRealFeignHttpCalls() throws Exception {
        mvc.perform(post("/api/rentings").contentType("application/json").content(request()))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.carName").value("Toyota Camry"))
            .andExpect(jsonPath("$.carModel").value("Camry 2.5Q"))
            .andExpect(jsonPath("$.totalPrice").value(3000000));
        assertEquals(1, repository.count());
        assertEquals(1, gets.get());
        assertEquals(1, reserves.get());
        mvc.perform(get("/api/rentings"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$[0].totalPrice").value(3000000));
        assertEquals(2, gets.get());
    }

    @Test
    void businessErrorsDoNotPersist() throws Exception {
        for (int code : new int[] { 404, 409, 208, 503 }) {
            mode.set(code);
            int expected = code == 208 ? 409 : code;
            String message =
                expected == 404
                    ? "Car not found"
                    : expected == 409
                      ? "Car is rented"
                      : "Car service unavailable";
            mvc.perform(post("/api/rentings").contentType("application/json").content(request()))
                .andExpect(status().is(expected))
                .andExpect(content().json("{\"error\":\"" + message + "\"}"));
            assertEquals(0, repository.count());
        }
    }

    @Test
    void outOfRangeDateIsRejectedBeforeReservingCar() throws Exception {
        mvc.perform(post("/api/rentings").contentType("application/json")
            .content(request().replace("2026-10-17", "+999999999-12-31")))
            .andExpect(status().isBadRequest())
            .andExpect(content().json("{\"error\":\"Invalid data\"}"));
        assertEquals(0, reserves.get());
        assertEquals(0, repository.count());
    }

    @Test
    void validationRunsBeforeFeign() throws Exception {
        for (String body : new String[] {
            "{}",
            request().replace("CUST-001", " "),
            request().replace("2026-10-17", "2026-10-15"),
            request().replace("2026-10-17", "2026-10-14"),
            request().replace("2026-10-17", "not-a-date"),
            request().replace("\"carId\":1", "\"carId\":null"),
        }) {
            mvc.perform(post("/api/rentings").contentType("application/json").content(body))
                .andExpect(status().isBadRequest())
                .andExpect(content().json("{\"error\":\"Invalid data\"}"));
        }
        assertEquals(0, repository.count());
        assertEquals(0, gets.get());
        assertEquals(0, reserves.get());
    }
}
