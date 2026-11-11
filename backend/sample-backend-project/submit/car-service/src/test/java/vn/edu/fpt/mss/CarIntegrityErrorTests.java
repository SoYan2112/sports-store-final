package vn.edu.fpt.mss;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import org.junit.jupiter.api.Test;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import vn.edu.fpt.mss.controller.CarController;
import vn.edu.fpt.mss.exception.GlobalExceptionHandler;
import vn.edu.fpt.mss.service.CarService;

class CarIntegrityErrorTests {

    @Test
    void duplicateNameOnCreateAndUpdateReturnsBadRequest() throws Exception {
        CarService service = mock(CarService.class);
        when(service.create(any())).thenThrow(new DataIntegrityViolationException("Duplicate car name"));
        when(service.update(anyInt(), any())).thenThrow(new DataIntegrityViolationException("Duplicate car name"));
        MockMvc mvc = MockMvcBuilders.standaloneSetup(new CarController(service))
            .setControllerAdvice(new GlobalExceptionHandler())
            .build();
        String body = """
            {"carName":"Toyota Camry 2","model":"Camry","color":"Red","pricePerDay":1200000,"status":"Available"}
            """;

        mvc.perform(post("/api/cars").contentType("application/json").content(body))
            .andExpect(status().isBadRequest())
            .andExpect(content().json("{\"error\":\"Invalid data\"}"));
        mvc.perform(put("/api/cars/1").contentType("application/json").content(body))
            .andExpect(status().isBadRequest())
            .andExpect(content().json("{\"error\":\"Invalid data\"}"));
    }
}
