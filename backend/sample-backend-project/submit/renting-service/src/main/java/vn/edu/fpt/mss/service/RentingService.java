package vn.edu.fpt.mss.service;

import java.util.List;
import vn.edu.fpt.mss.dto.request.RentingRequest;
import vn.edu.fpt.mss.dto.response.RentingResponse;

public interface RentingService {
    RentingResponse create(RentingRequest request);
    List<RentingResponse> findAll();
}
