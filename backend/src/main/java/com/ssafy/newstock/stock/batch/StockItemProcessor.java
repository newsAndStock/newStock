package com.ssafy.newstock.stock.batch;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssafy.newstock.stock.domain.Stock;
import com.ssafy.newstock.stock.domain.StockInfo;
import com.ssafy.newstock.stock.service.FetchStockService;
import lombok.RequiredArgsConstructor;
import org.springframework.batch.item.ItemProcessor;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
@RequiredArgsConstructor
public class StockItemProcessor implements ItemProcessor<Stock, StockInfo> {

    private final FetchStockService fetchStockService;
    private final ObjectMapper objectMapper;

    @Override
    public StockInfo process(Stock stock) throws Exception {
        String stockCode = stock.getStockCode();
        String currentDate = LocalDate.now().toString();

        String responseData = fetchStockService.fetchStockData(stockCode, currentDate, currentDate, "D");

        JsonNode root = objectMapper.readTree(responseData);
        JsonNode output2 = root.path("output2");

        if (output2.isEmpty() || output2.get(0).isEmpty()) {
            return null;
        }

        JsonNode stockData = output2.get(0);
        return new StockInfo(
                stockData.get("stck_bsop_date").asText(),
                stockData.get("stck_hgpr").asText(), stockData.get("stck_lwpr").asText(),
                stockData.get("stck_oprc").asText(), stockData.get("stck_clpr").asText(),
                stockData.get("acml_vol").asLong(), stockCode, "day"
        );
    }
}
