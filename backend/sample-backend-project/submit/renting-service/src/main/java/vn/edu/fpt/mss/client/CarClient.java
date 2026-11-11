package vn.edu.fpt.mss.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.mss.dto.client.CarInfo;

@FeignClient(name = "car-service", url = "${services.car-url}")
public interface CarClient {
    @GetMapping("/api/cars/{id}")
    CarInfo findById(@PathVariable("id") Integer id);

    @PostMapping("/internal/cars/{id}/reserve")
    CarInfo reserve(@PathVariable("id") Integer id);
}
