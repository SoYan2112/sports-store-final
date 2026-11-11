package vn.edu.fpt.mss;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest(
    properties = {
        "spring.datasource.url=jdbc:h2:mem:cars;MODE=MSSQLServer;DB_CLOSE_DELAY=-1",
        "spring.datasource.username=sa",
        "spring.datasource.password=",
        "spring.jpa.hibernate.ddl-auto=create-drop",
    }
)
@AutoConfigureMockMvc
class CarApiTests {

    @Autowired
    MockMvc mvc;

    @Autowired
    ObjectMapper json;

    private String car(String status) {
        return """
        {"carName":"VinFast VF8","model":"VF8 Plus","color":"Red","pricePerDay":1200000,"status":"%s"}
        """.formatted(status);
    }

    @Test
    void crudAndRentedProtection() throws Exception {
        String body = mvc
            .perform(post("/api/cars").contentType("application/json").content(car("Available")))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.carName").value("VinFast VF8"))
            .andReturn()
            .getResponse()
            .getContentAsString();
        int id = json.readTree(body).get("carId").asInt();
        mvc.perform(get("/api/cars"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$[0].carId").exists());
        mvc.perform(get("/api/cars/{id}", id))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.model").value("VF8 Plus"));
        mvc.perform(
            put("/api/cars/{id}", id).contentType("application/json").content(car("Rented"))
        ).andExpect(status().isOk());
        mvc.perform(delete("/api/cars/{id}", id))
            .andExpect(status().isConflict())
            .andExpect(content().json("{\"error\":\"Car is rented\"}"));
        mvc.perform(get("/api/cars/{id}", id)).andExpect(status().isOk());
        mvc.perform(
            put("/api/cars/{id}", id).contentType("application/json").content(car("Available"))
        ).andExpect(status().isOk());
        mvc.perform(delete("/api/cars/{id}", id))
            .andExpect(status().isNoContent())
            .andExpect(content().string(""));
        mvc.perform(get("/api/cars/{id}", id))
            .andExpect(status().isNotFound())
            .andExpect(content().json("{\"error\":\"Car not found\"}"));
    }

    @Test
    void invalidAndMissing() throws Exception {
        for (String body : new String[] {
            "{}",
            car("Available").replace("1200000", "0"),
            car("Available").replace("VF8 Plus", " "),
            "{",
            car("Available").replace("1200000", "null"),
        }) {
            mvc.perform(post("/api/cars").contentType("application/json").content(body))
                .andExpect(status().isBadRequest())
                .andExpect(content().json("{\"error\":\"Invalid data\"}"));
            mvc.perform(
                put("/api/cars/99999").contentType("application/json").content(body)
            ).andExpect(status().isBadRequest());
        }
        mvc.perform(
            put("/api/cars/99999").contentType("application/json").content(car("Available"))
        ).andExpect(status().isNotFound());
        mvc.perform(delete("/api/cars/99999")).andExpect(status().isNotFound());
    }

    @Test
    void reserveIsExclusive() throws Exception {
        String body = mvc
            .perform(post("/api/cars").contentType("application/json").content(car("Available")))
            .andReturn()
            .getResponse()
            .getContentAsString();
        int id = json.readTree(body).get("carId").asInt();
        mvc.perform(post("/internal/cars/{id}/reserve", id))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.status").value("Rented"));
        mvc.perform(post("/internal/cars/{id}/reserve", id)).andExpect(status().isConflict());
    }
}
