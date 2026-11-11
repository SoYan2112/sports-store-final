package vn.edu.fpt.mss.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.mss.dto.response.CarResponse;
import vn.edu.fpt.mss.service.CarService;

@RestController
@RequestMapping("/internal/cars")
@RequiredArgsConstructor
public class InternalCarController {

    private final CarService service;

    @PostMapping("/{id}/reserve")
    public CarResponse reserve(@PathVariable Integer id) {
        return service.reserve(id);
    }
}
