package com.ssafy.newstock.stock.batch;

import com.ssafy.newstock.stock.domain.StockInfo;
import com.ssafy.newstock.stock.repository.StockInfoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.batch.item.Chunk;
import org.springframework.batch.item.ItemWriter;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class StockItemWriter implements ItemWriter<StockInfo> {

    private final StockInfoRepository stockInfoRepository;

    @Override
    public void write(Chunk<? extends StockInfo> stockInfos) throws Exception {
        for (StockInfo stockInfo : stockInfos) {
            if (stockInfo != null) {
                stockInfoRepository.save(stockInfo);
            }
        }
    }
}
