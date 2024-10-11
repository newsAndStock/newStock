package com.ssafy.newstock.stock.batch.minute;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssafy.newstock.stock.domain.MinuteStockInfo;
import com.ssafy.newstock.stock.domain.Stock;
import com.ssafy.newstock.stock.service.FetchStockService;
import lombok.RequiredArgsConstructor;
import org.springframework.batch.item.ItemProcessor;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Component
@RequiredArgsConstructor
public class MinuteStockItemProcessor implements ItemProcessor<Stock, MinuteStockInfo> {

    private final FetchStockService fetchStockService;
    private final ObjectMapper objectMapper;

    @Override
    public MinuteStockInfo process(Stock stock) throws Exception {
        String stockCode = stock.getStockCode();
        String currentTime = LocalDateTime.now()
                .withMinute((LocalDateTime.now().getMinute() / 10) * 10)
                .format(DateTimeFormatter.ofPattern("HHmm")) + "00";

        String responseData = fetchStockService.fetchMinuteStockData(stockCode, currentTime);

        JsonNode root = objectMapper.readTree(responseData);
        JsonNode output2 = root.path("output2");

        String openingPrice = output2.get(output2.size() - 1).path("stck_oprc").asText();
        String closingPrice = output2.get(0).path("stck_prpr").asText();
        String highestPrice = output2.get(0).path("stck_hgpr").asText();
        String lowestPrice = output2.get(0).path("stck_lwpr").asText();

        long totalVolume = 0;

        for (int i = 0; i < 10; i++) {
            JsonNode stockData = output2.get(i);
            String currentHigh = stockData.path("stck_hgpr").asText();
            String currentLow = stockData.path("stck_lwpr").asText();
            long volume = stockData.path("cntg_vol").asLong();

            if (currentHigh.compareTo(highestPrice) > 0) highestPrice = currentHigh;
            if (currentLow.compareTo(lowestPrice) < 0) lowestPrice = currentLow;

            totalVolume += volume;
        }

        return new MinuteStockInfo(stockCode, currentTime, openingPrice, closingPrice, highestPrice, lowestPrice, totalVolume);
    }
}
