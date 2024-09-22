package com.ssafy.newstock.stock.service;

import com.ssafy.newstock.stock.controller.response.StockInfoResponse;
import com.ssafy.newstock.stock.domain.StockInfo;
import com.ssafy.newstock.stock.repository.StockInfoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StockService {
    private final StockInfoRepository stockInfoRepository;
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyyMMdd");

    public List<StockInfoResponse> getStockInfo(String stockCode, String period) {
        LocalDate currentDate = LocalDate.now();
        LocalDate startDate = switch (period) {
            case "day" -> currentDate.minusMonths(3);
            case "week" -> currentDate.minusYears(1);
            case "month" -> currentDate.minusYears(5);
            default -> throw new IllegalArgumentException("기간 잘못 입력");
        };

        List<StockInfo> stockInfoList = stockInfoRepository.findDataWithinRange(startDate.format(FORMATTER), stockCode, period);

        return stockInfoList.stream()
                .map(StockInfoResponse::from)
                .collect(Collectors.toList());
    }
}
