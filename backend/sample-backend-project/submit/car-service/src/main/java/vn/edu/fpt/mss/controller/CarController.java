package vn.edu.fpt.mss.controller;

import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.mss.dto.request.CarRequest;
import vn.edu.fpt.mss.dto.response.CarResponse;
import vn.edu.fpt.mss.service.CarService;

@RestController
@RequestMapping("/api/cars")
@RequiredArgsConstructor
public class CarController {

    private final CarService service;

    @PostMapping
    public ResponseEntity<CarResponse> create(@Valid @RequestBody CarRequest request) {
        CarResponse c = service.create(request);
        return ResponseEntity.created(URI.create("/api/cars/" + c.carId())).body(c);
    }

    @GetMapping
    public List<CarResponse> findAll() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public CarResponse findById(@PathVariable Integer id) {
        return service.findById(id);
    }

    @PutMapping("/{id}")
    public CarResponse update(@PathVariable Integer id, @Valid @RequestBody CarRequest request) {
        return service.update(id, request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Integer id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
