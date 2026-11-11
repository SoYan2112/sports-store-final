package vn.edu.fpt.mss;

import static org.junit.jupiter.api.Assertions.*;

import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.*;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class GatewayTests {

    static HttpServer cars, rentings;

    static HttpServer echo(String name) throws IOException {
        HttpServer server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        server.createContext("/", ex -> {
            byte[] bytes = ex.getRequestBody().readAllBytes();
            if (bytes.length == 0) bytes = "[]".getBytes(StandardCharsets.UTF_8);
            ex.getResponseHeaders().set("Content-Type", "application/json");
            ex.getResponseHeaders().set("X-Service", name);
            ex.getResponseHeaders().set(
                "X-Forwarded-Test",
                ex.getRequestHeaders().getFirst("X-Test")
            );
            ex.getResponseHeaders().set("X-Path", ex.getRequestURI().toString());
            ex.sendResponseHeaders(201, bytes.length);
            ex.getResponseBody().write(bytes);
            ex.close();
        });
        server.start();
        return server;
    }

    @DynamicPropertySource
    static void routes(DynamicPropertyRegistry p) throws IOException {
        cars = echo("car-service");
        rentings = echo("renting-service");
        p.add("spring.cloud.gateway.server.webflux.routes[0].id", () -> "car-service");
        p.add(
            "spring.cloud.gateway.server.webflux.routes[0].uri",
            () -> "http://127.0.0.1:" + cars.getAddress().getPort()
        );
        p.add(
            "spring.cloud.gateway.server.webflux.routes[0].predicates[0]",
            () -> "Path=/api/cars,/api/cars/**"
        );
        p.add("spring.cloud.gateway.server.webflux.routes[1].id", () -> "renting-service");
        p.add(
            "spring.cloud.gateway.server.webflux.routes[1].uri",
            () -> "http://127.0.0.1:" + rentings.getAddress().getPort()
        );
        p.add(
            "spring.cloud.gateway.server.webflux.routes[1].predicates[0]",
            () -> "Path=/api/rentings,/api/rentings/**"
        );
    }

    @AfterAll
    static void stop() {
        cars.stop(0);
        rentings.stop(0);
    }

    @Autowired
    TestRestTemplate http;

    @Test
    void bodiesHeadersPathsAndResponsesPassThrough() {
        for (String path : new String[] {
            "/api/cars",
            "/api/cars/7?check=1",
            "/api/rentings",
            "/api/rentings/7",
        }) {
            String body = "{\"customerId\":\"CUST-001\",\"carId\":1}";
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("X-Test", "unchanged");
            ResponseEntity<String> response = http.exchange(
                path,
                HttpMethod.POST,
                new HttpEntity<>(body, headers),
                String.class
            );
            assertEquals(201, response.getStatusCode().value());
            assertEquals(body, response.getBody());
            assertEquals("unchanged", response.getHeaders().getFirst("X-Forwarded-Test"));
            assertEquals(path, response.getHeaders().getFirst("X-Path"));
            assertEquals(
                path.startsWith("/api/cars") ? "car-service" : "renting-service",
                response.getHeaders().getFirst("X-Service")
            );
        }
    }

    @Test
    void otherPathsAre404() {
        for (String path : new String[] {
            "/",
            "/api/other",
            "/internal/cars/1/reserve",
            "/api/cars-extra",
        })
            assertEquals(404, http.getForEntity(path, String.class).getStatusCode().value());
    }
}
