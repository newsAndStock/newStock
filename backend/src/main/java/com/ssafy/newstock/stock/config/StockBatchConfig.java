package com.ssafy.newstock.stock.config;

import com.ssafy.newstock.stock.batch.StockItemProcessor;
import com.ssafy.newstock.stock.batch.StockItemReader;
import com.ssafy.newstock.stock.batch.StockItemWriter;
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
    private final StockItemReader stockItemReader;
    private final StockItemProcessor stockItemProcessor;
    private final StockItemWriter stockItemWriter;

    @Bean
    public Job stockDataJob(Step stockDataStep) {
        return new JobBuilder("stockDataJob", jobRepository)
                .incrementer(new RunIdIncrementer())
                .start(stockDataStep)
                .build();
    }

    @Bean
    public Step stockDataStep() {
        return new StepBuilder("stockDataStep", jobRepository)
                .<Stock, StockInfo>chunk(100, transactionManager)
                .reader(stockItemReader)
                .processor(stockItemProcessor)
                .writer(stockItemWriter)
                .build();
    }
}
