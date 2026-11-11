package vn.edu.fpt.mss.service.impl;

import feign.FeignException;
import java.math.BigDecimal;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.function.Supplier;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.fpt.mss.client.CarClient;
import vn.edu.fpt.mss.dto.client.CarInfo;
import vn.edu.fpt.mss.dto.request.RentingRequest;
import vn.edu.fpt.mss.dto.response.RentingResponse;
import vn.edu.fpt.mss.entity.Renting;
import vn.edu.fpt.mss.exception.ApiException;
import vn.edu.fpt.mss.repository.RentingRepository;
import vn.edu.fpt.mss.service.RentingService;

@Service
@RequiredArgsConstructor
public class RentingServiceImpl implements RentingService {

    private final RentingRepository repository;
    private final CarClient carClient;

    private CarInfo callCar(Supplier<CarInfo> action) {
        try {
            CarInfo result = action.get();
            if (result == null || result.status() == null) {
                throw new ApiException(503, "Invalid response from car service");
            }
            return result;
        } catch (FeignException.NotFound ex) {
            throw new ApiException(404, "Car not found");
        } catch (FeignException.Conflict ex) {
            throw new ApiException(409, "Car is rented");
        } catch (FeignException ex) {
            throw new ApiException(503, "Car service unavailable");
        }
    }

    @Override
    @Transactional
    public RentingResponse create(RentingRequest r) {
        if (r.rentStartDate().getYear() < 1 || r.rentStartDate().getYear() > 9999
            || r.rentEndDate().getYear() < 1 || r.rentEndDate().getYear() > 9999
            || !r.rentEndDate().isAfter(r.rentStartDate())) throw new ApiException(
            400,
            "Invalid data"
        );
        CarInfo car = callCar(() -> carClient.findById(r.carId()));
        if (!"Available".equals(car.status())) throw new ApiException(409, "Car is rented");
        if (car.pricePerDay() == null || car.pricePerDay().signum() <= 0) {
            throw new ApiException(503, "Invalid response from car service");
        }
        BigDecimal totalPrice = car.pricePerDay().multiply(
            BigDecimal.valueOf(ChronoUnit.DAYS.between(r.rentStartDate(), r.rentEndDate()))
        );
        if (totalPrice.compareTo(new BigDecimal("9999999999999999.99")) > 0) {
            throw new ApiException(400, "Invalid data");
        }
        Renting entity = new Renting();
        entity.setCustomerId(r.customerId());
        entity.setCarId(r.carId());
        entity.setRentStartDate(r.rentStartDate());
        entity.setRentEndDate(r.rentEndDate());
        entity.setTotalPrice(totalPrice);
        entity = repository.saveAndFlush(entity);
        car = callCar(() -> carClient.reserve(r.carId()));
        return response(entity, car);
    }

    @Override
    @Transactional(readOnly = true)
    public List<RentingResponse> findAll() {
        return repository
            .findAll(Sort.by("rentingId"))
            .stream()
            .map(r -> response(r, callCar(() -> carClient.findById(r.getCarId()))))
            .toList();
    }

    private RentingResponse response(Renting r, CarInfo c) {
        return new RentingResponse(
            r.getRentingId(),
            r.getCustomerId(),
            r.getCarId(),
            c.carName(),
            c.model(),
            r.getRentStartDate(),
            r.getRentEndDate(),
            r.getTotalPrice()
        );
    }
}
