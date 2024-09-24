package com.ssafy.newstock.stock.batch;

import lombok.RequiredArgsConstructor;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.JobParametersBuilder;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

import java.time.LocalDate;
import java.util.Set;

@Configuration
@EnableScheduling
@RequiredArgsConstructor
public class StockBatchScheduler {
    private final JobLauncher jobLauncher;
    private final Job stockDataJob;
    private final Set<LocalDate> holidays = Set.of(
            LocalDate.of(2024, 10, 1),
            LocalDate.of(2024, 10, 3),
            LocalDate.of(2024, 10, 9)
    );

    @Scheduled(cron = "0 30 16 * * MON-FRI", zone = "Asia/Seoul")
    public void runStockDataJob() throws Exception {
        LocalDate today = LocalDate.now();
        if (holidays.contains(today)) return;

        jobLauncher.run(
                stockDataJob,
                new JobParametersBuilder()
                        .addLong("time", System.currentTimeMillis())
                        .toJobParameters()
        );
    }
}
