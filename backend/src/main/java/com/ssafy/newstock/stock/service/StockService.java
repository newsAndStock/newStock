package com.ssafy.newstock.stock.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssafy.newstock.common.util.WebClientUtil;
import com.ssafy.newstock.stock.domain.Stock;
import com.ssafy.newstock.stock.domain.StockInfo;
import com.ssafy.newstock.stock.repository.StockInfoRepository;
import com.ssafy.newstock.stock.repository.StockRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class StockService {

    private final ObjectMapper objectMapper;
    private final WebClientUtil webClientUtil;
    private final StockRepository stockRepository;
    private final StockInfoRepository stockInfoRepository;

    public String fetchStockData(String stockCode, String startDate, String endDate, String period) {
        String url = "/uapi/domestic-stock/v1/quotations/inquire-daily-itemchartprice";

        Map<String, String> queryParams = Map.of(
                "fid_cond_mrkt_div_code", "J",
                "fid_input_iscd", stockCode,
                "fid_input_date_1", LocalDate.parse(startDate).format(DateTimeFormatter.ofPattern("yyyyMMdd")),
                "fid_input_date_2", LocalDate.parse(endDate).format(DateTimeFormatter.ofPattern("yyyyMMdd")),
                "fid_period_div_code", period,
                "fid_org_adj_prc", "1"
        );

        try {
            log.info("주식 데이터 가져오기: {}, period: {}, startDate: {}, endDate: {}", stockCode, period, startDate, endDate);
            return webClientUtil.sendRequest(url, queryParams, null);
        } catch (Exception ex) {
            throw new RuntimeException("주식 데이터 가져오기 실패: " + stockCode, ex);
        }
    }

    public void processStockData() {
        List<Stock> stocks = stockRepository.findAll();
        LocalDate currentDate = LocalDate.now();

        for (Stock stock : stocks) {
            String startDate = determineStartDate(stock.getListingDate());
            String stockCode = stock.getStockCode();

            String dayData = fetchStockData(stockCode, startDate, currentDate.toString(), "D");
            saveStockData(parseResponse(dayData, stockCode, "day"));

            String weeklyData = fetchStockData(stockCode, startDate, currentDate.toString(), "W");
            saveStockData(parseResponse(weeklyData, stockCode, "week"));

            String monthlyData = fetchStockData(stockCode, startDate, currentDate.toString(), "M");
            saveStockData(parseResponse(monthlyData, stockCode, "month"));
        }
    }

    private String determineStartDate(String listingDate) {
        LocalDate listing = LocalDate.parse(listingDate, DateTimeFormatter.ofPattern("yyyy/MM/dd"));
        return listing.isBefore(LocalDate.of(2020, 1, 1)) ? "2020-01-01" : listing.toString();
    }

    private void saveStockData(List<StockInfo> stockInfoList) {
        stockInfoRepository.saveAll(stockInfoList);
    }

    public List<StockInfo> parseResponse(String response, String stockCode, String period) {
        List<StockInfo> stockInfoList = new ArrayList<>();

        try {
            JsonNode root = objectMapper.readTree(response);
            JsonNode output2 = root.get("output2");

            for (JsonNode stockData : output2) {
                String date = stockData.get("stck_bsop_date").asText();
                String highestPrice = stockData.get("stck_hgpr").asText();
                String lowestPrice = stockData.get("stck_lwpr").asText();
                String openingPrice = stockData.get("stck_oprc").asText();
                String closingPrice = stockData.get("stck_clpr").asText();
                long volume = stockData.get("acml_vol").asLong();

                StockInfo stockInfo = new StockInfo(date, highestPrice, lowestPrice, openingPrice, closingPrice, volume, stockCode, period);
                stockInfoList.add(stockInfo);
            }
        } catch (Exception e) {
            throw new RuntimeException("주식 데이터 파싱 실패", e);
        }

        return stockInfoList;
    }
}
