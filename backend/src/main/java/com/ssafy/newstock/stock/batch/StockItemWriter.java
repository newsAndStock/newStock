package com.ssafy.newstock.stock.batch;

import com.ssafy.newstock.stock.domain.StockInfo;
import com.ssafy.newstock.stock.repository.StockInfoBulkInsertRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.batch.item.Chunk;
import org.springframework.batch.item.ItemWriter;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class StockItemWriter implements ItemWriter<StockInfo> {

    private final StockInfoBulkInsertRepository stockInfoBulkInsertRepository;

    @Override
    public void write(Chunk<? extends StockInfo> stockInfos) {
        stockInfoBulkInsertRepository.bulkInsert((List<StockInfo>) stockInfos.getItems());
    }
}
