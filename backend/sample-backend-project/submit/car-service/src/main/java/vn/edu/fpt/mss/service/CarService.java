package vn.edu.fpt.mss.service;

import java.util.List;
import vn.edu.fpt.mss.dto.request.CarRequest;
import vn.edu.fpt.mss.dto.response.CarResponse;

public interface CarService {
    CarResponse create(CarRequest request);
    List<CarResponse> findAll();
    CarResponse findById(Integer id);
    CarResponse update(Integer id, CarRequest request);
    void delete(Integer id);
    CarResponse reserve(Integer id);
}
