package com.ssafy.newstock.stock.config;

import com.ssafy.newstock.stock.batch.day.DayStockItemProcessor;
import com.ssafy.newstock.stock.batch.day.DayStockItemReader;
import com.ssafy.newstock.stock.batch.day.DayStockItemWriter;
import com.ssafy.newstock.stock.batch.minute.MinuteStockItemProcessor;
import com.ssafy.newstock.stock.batch.minute.MinuteStockItemReader;
import com.ssafy.newstock.stock.batch.minute.MinuteStockItemWriter;
import com.ssafy.newstock.stock.domain.MinuteStockInfo;
import com.ssafy.newstock.stock.domain.Stock;
import com.ssafy.newstock.stock.domain.StockInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.job.builder.JobBuilder;
import org.springframework.batch.core.launch.support.RunIdIncrementer;
import org.springframework.batch.core.repository.JobRepository;
import org.springframework.batch.core.step.builder.StepBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.PlatformTransactionManager;

@Configuration
@EnableBatchProcessing
@RequiredArgsConstructor
public class StockBatchConfig {

    private final JobRepository jobRepository;
    private final PlatformTransactionManager transactionManager;
    private final DayStockItemReader dayStockItemReader;
    private final DayStockItemProcessor dayStockItemProcessor;
    private final DayStockItemWriter dayStockItemWriter;
    private final MinuteStockItemReader minuteStockItemReader;
    private final MinuteStockItemProcessor minuteStockItemProcessor;
    private final MinuteStockItemWriter minuteStockItemWriter;

    @Bean
    public Job dayStockDataJob(Step dayStockDataStep) {
        return new JobBuilder("dayStockDataJob", jobRepository)
                .incrementer(new RunIdIncrementer())
                .start(dayStockDataStep)
                .build();
    }

    @Bean
    public Step dayStockDataStep() {
        return new StepBuilder("dayStockDataStep", jobRepository)
                .<Stock, StockInfo>chunk(100, transactionManager)
                .reader(dayStockItemReader)
                .processor(dayStockItemProcessor)
                .writer(dayStockItemWriter)
                .build();
    }

    @Bean
    public Job minuteStockDataJob(Step minuteStockDataStep) {
        return new JobBuilder("minuteStockDataJob", jobRepository)
                .incrementer(new RunIdIncrementer())
                .start(minuteStockDataStep)
                .build();
    }

    @Bean
    public Step minuteStockDataStep() {
        return new StepBuilder("minuteStockDataStep", jobRepository)
                .<Stock, MinuteStockInfo>chunk(100, transactionManager)
                .reader(minuteStockItemReader)
                .processor(minuteStockItemProcessor)
                .writer(minuteStockItemWriter)
                .build();
    }
}
