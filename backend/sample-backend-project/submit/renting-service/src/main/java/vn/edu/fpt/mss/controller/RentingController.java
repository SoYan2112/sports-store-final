package vn.edu.fpt.mss.controller;

import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import vn.edu.fpt.mss.dto.request.RentingRequest;
import vn.edu.fpt.mss.dto.response.RentingResponse;
import vn.edu.fpt.mss.service.RentingService;

@RestController
@RequestMapping("/api/rentings")
@RequiredArgsConstructor
public class RentingController {

    private final RentingService service;

    @PostMapping
    public ResponseEntity<RentingResponse> create(@Valid @RequestBody RentingRequest r) {
        RentingResponse result = service.create(r);
        return ResponseEntity.created(URI.create("/api/rentings")).body(result);
    }

    @GetMapping
    public List<RentingResponse> findAll() {
        return service.findAll();
    }
}
