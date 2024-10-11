package com.ssafy.newstock.stock.batch.minute;

import com.ssafy.newstock.stock.domain.MinuteStockInfo;
import com.ssafy.newstock.stock.repository.MinuteStockInfoBulkInsertRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.batch.item.Chunk;
import org.springframework.batch.item.ItemWriter;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class MinuteStockItemWriter implements ItemWriter<MinuteStockInfo> {

    private final MinuteStockInfoBulkInsertRepository minuteStockInfoBulkInsertRepository;

    @Override
    public void write(Chunk<? extends MinuteStockInfo> infos) {
        minuteStockInfoBulkInsertRepository.bulkInsert((List<MinuteStockInfo>) infos.getItems());
    }
}
