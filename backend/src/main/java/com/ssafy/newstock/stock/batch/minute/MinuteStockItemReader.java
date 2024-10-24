package com.ssafy.newstock.stock.batch.minute;

import com.ssafy.newstock.stock.domain.Stock;
import com.ssafy.newstock.stock.repository.StockRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.batch.item.ItemReader;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class MinuteStockItemReader implements ItemReader<Stock> {

    private final StockRepository stockRepository;
    private List<Stock> stockList;
    private int index = 0;

    @Override
    public Stock read() {
        if (index == 0) {
            stockList = stockRepository.findAll();
        }

        if (index < stockList.size()) {
            return stockList.get(index++);
        }

        index = 0;
        return null;
    }
}
