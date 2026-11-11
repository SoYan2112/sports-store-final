package vn.edu.fpt.mss.service.impl;

import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.mss.dto.request.CarRequest;
import vn.edu.fpt.mss.dto.response.CarResponse;
import vn.edu.fpt.mss.entity.Car;
import vn.edu.fpt.mss.exception.ApiException;
import vn.edu.fpt.mss.repository.CarRepository;
import vn.edu.fpt.mss.service.CarService;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CarServiceImpl implements CarService {

    private final CarRepository repository;

    private Car findCarOrThrow(Integer carId) {
        return repository.findById(carId).orElseThrow(() -> new ApiException(404, "Car not found"));
    }

    private Car findCarForUpdate(Integer carId) {
        return repository
            .findLockedById(carId)
            .orElseThrow(() -> new ApiException(404, "Car not found"));
    }

    private void updateCarFields(Car car, CarRequest request) {
        car.setCarName(request.carName());
        car.setModel(request.model());
        car.setColor(request.color());
        car.setPricePerDay(request.pricePerDay());
        car.setStatus(request.status());
    }

    @Override
    @Transactional
    public CarResponse create(CarRequest request) {
        Car car = new Car();
        updateCarFields(car, request);
        return toResponse(repository.save(car));
    }

    @Override
    public List<CarResponse> findAll() {
        return repository.findAll(Sort.by("carId")).stream().map(this::toResponse).toList();
    }

    @Override
    public CarResponse findById(Integer carId) {
        return toResponse(findCarOrThrow(carId));
    }

    @Override
    @Transactional
    public CarResponse update(Integer carId, CarRequest request) {
        Car car = findCarForUpdate(carId);
        updateCarFields(car, request);
        return toResponse(repository.save(car));
    }

    @Override
    @Transactional
    public void delete(Integer carId) {
        Car car = findCarForUpdate(carId);
        if ("Rented".equals(car.getStatus())) throw new ApiException(409, "Car is rented");
        repository.delete(car);
    }

    @Override
    @Transactional
    public CarResponse reserve(Integer carId) {
        Car car = findCarForUpdate(carId);
        if (!"Available".equals(car.getStatus())) throw new ApiException(409, "Car is rented");
        car.setStatus("Rented");
        return toResponse(repository.save(car));
    }

    private CarResponse toResponse(Car car) {
        return new CarResponse(
            car.getCarId(),
            car.getCarName(),
            car.getModel(),
            car.getColor(),
            car.getPricePerDay(),
            car.getStatus()
        );
    }
}
