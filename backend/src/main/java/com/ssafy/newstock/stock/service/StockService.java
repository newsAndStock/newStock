package com.ssafy.newstock.stock.service;

import com.ssafy.newstock.memberstocks.repository.MemberStocksRepository;
import com.ssafy.newstock.stock.controller.response.MinuteStockInfoResponse;
import com.ssafy.newstock.stock.controller.response.StockHoldingsResponse;
import com.ssafy.newstock.stock.controller.response.StockInfoResponse;
import com.ssafy.newstock.stock.domain.StockInfo;
import com.ssafy.newstock.stock.repository.MinuteStockInfoRepository;
import com.ssafy.newstock.stock.repository.StockInfoRepository;
import com.ssafy.newstock.stock.repository.StockRepository;
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
    private final MinuteStockInfoRepository minuteStockInfoRepository;
    private final StockRepository stockRepository;
    private final MemberStocksRepository memberStocksRepository;

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

    public List<MinuteStockInfoResponse> getDailyStockInfo(String stockCode) {
        return minuteStockInfoRepository.findByStockCode(stockCode)
                .stream()
                .map(MinuteStockInfoResponse::from)
                .collect(Collectors.toList());
    }

    public StockHoldingsResponse getMemberStockHoldings(Long memberId, String stockCode) {
        Long holdingsCount = getHoldingsByMemberAndStockCode(memberId, stockCode);
        return new StockHoldingsResponse(findNameByStockCode(stockCode), holdingsCount);
    }

    public String findNameByStockCode(String stockCode) {
        return stockRepository.findByStockCode(stockCode)
                .orElseThrow(() -> new IllegalArgumentException("잘못된 주식 코드입니다."))
                .getName();
    }

    public Long getHoldingsByMemberAndStockCode(Long memberId, String stockCode) {
        return memberStocksRepository
                .getHoldingsByMember_IdAndStockCode(memberId, stockCode)
                .orElse(0L);
    }
}
