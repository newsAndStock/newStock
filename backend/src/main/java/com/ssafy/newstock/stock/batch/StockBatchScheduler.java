package com.ssafy.newstock.stock.batch;

import com.ssafy.newstock.common.util.BatchNotificationSender;
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
    private final Job dayStockDataJob;
    private final Job minuteStockDataJob;
    private final BatchNotificationSender batchNotificationSender;

    private final Set<LocalDate> holidays = Set.of(
            LocalDate.of(2024, 10, 1),
            LocalDate.of(2024, 10, 3),
            LocalDate.of(2024, 10, 9)
    );

    @Scheduled(cron = "0 30 16 * * MON-FRI", zone = "Asia/Seoul")
    public void runStockDataJob() {
        runBatchJob("일 단위 주식 데이터 작업", dayStockDataJob);
    }

    @Scheduled(cron = "0 30,0 9-15 * * MON-FRI", zone = "Asia/Seoul")
//    @Scheduled(cron = "0 38 15 * * *", zone = "Asia/Seoul")
    public void runMinuteStockDataJob() {
        runBatchJob("분 단위 주식 데이터 작업", minuteStockDataJob);
    }

    private void runBatchJob(String jobDescription, Job job) {
        LocalDate today = LocalDate.now();
        if (holidays.contains(today)) return;

        batchNotificationSender.sendNotificationToMattermost("배치 시작: " + jobDescription);

        try {
            jobLauncher.run(
                    job,
                    new JobParametersBuilder()
                            .addLong("time", System.currentTimeMillis())
                            .toJobParameters()
            );
            batchNotificationSender.sendNotificationToMattermost("배치 완료: " + jobDescription);
        } catch (Exception e) {
            batchNotificationSender.sendNotificationToMattermost("배치 작업 실패: " + jobDescription + " - " + e.getMessage());
        }
    }
}
