package vn.edu.fpt.mss;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;
import static org.mockito.ArgumentMatchers.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import org.junit.jupiter.api.Test;
import org.springframework.dao.DataIntegrityViolationException;
import vn.edu.fpt.mss.client.CarClient;
import vn.edu.fpt.mss.dto.client.CarInfo;
import vn.edu.fpt.mss.dto.request.RentingRequest;
import vn.edu.fpt.mss.exception.ApiException;
import vn.edu.fpt.mss.repository.RentingRepository;
import vn.edu.fpt.mss.service.impl.RentingServiceImpl;

class RentingFailureTests {
    @Test
    void invalidTotalAndFailedInsertDoNotReserveCar() {
        RentingRepository repository = mock(RentingRepository.class);
        CarClient client = mock(CarClient.class);
        RentingServiceImpl service = new RentingServiceImpl(repository, client);
        RentingRequest request = new RentingRequest("CUST-001", 1,
            LocalDate.of(2026, 10, 15), LocalDate.of(2026, 10, 17));
        when(client.findById(1)).thenReturn(new CarInfo(1, "Car", "Model", "Red",
            new BigDecimal("9999999999999999.99"), "Available"));
        assertEquals(400, assertThrows(ApiException.class, () -> service.create(request)).getStatus());
        verifyNoInteractions(repository);
        verify(client, never()).reserve(anyInt());

        when(client.findById(1)).thenReturn(new CarInfo(1, "Car", "Model", "Red",
            new BigDecimal("1500000"), "Available"));
        when(repository.saveAndFlush(any())).thenThrow(new DataIntegrityViolationException("constraint"));
        assertThrows(DataIntegrityViolationException.class, () -> service.create(request));
        verify(client, never()).reserve(anyInt());
    }
}
