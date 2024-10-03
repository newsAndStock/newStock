package com.ssafy.newstock.rank.service;



import org.springframework.data.redis.core.RedisTemplate;

import org.springframework.data.redis.core.ZSetOperations;
import org.springframework.stereotype.Service;


import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Date;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class RedisService {

    private final RedisTemplate<String, Object> redisTemplateRank; // 키: String, 값: Double

    public RedisService(RedisTemplate<String, Object> redisTemplateRank) {
        this.redisTemplateRank = redisTemplateRank; // RedisTemplate 주입
    }

    public void addMemberRank(Long memberId, double roi) {

        redisTemplateRank.opsForZSet().add("memberRank", memberId, roi);

    }

    public void setRankTime(){
        // 현재 시간을 "yyyy-MM-dd" 형식으로 가져오기
        String currentDate = new SimpleDateFormat("yyyy-MM-dd").format(new Date());

        // 랭킹 저장 시간 기록
        redisTemplateRank.opsForValue().set("rankSaveTime", currentDate);
    }

    public String getRankTime() {
        // Redis에서 랭킹 저장 시간을 읽어오기
        String rankSaveTime = (String) redisTemplateRank.opsForValue().get("rankSaveTime");
        return rankSaveTime != null ? rankSaveTime : "시간 정보가 없습니다."; // 값이 없을 경우 메시지 반환
    }



    public Map<Long, Double> getAllMembersWithScores() {
        Set<ZSetOperations.TypedTuple<Object>> topMembersWithScores =
                redisTemplateRank.opsForZSet().reverseRangeWithScores("memberRank", 0, -1);

        return topMembersWithScores != null
                ? topMembersWithScores.stream()
                .collect(Collectors.toMap(
                        tuple -> {
                            Object value = tuple.getValue();
                            if (value instanceof Long) {
                                return (Long) value;
                            } else if (value instanceof Integer) {
                                // Integer를 Long으로 변환
                                return ((Integer) value).longValue();
                            } else if (value instanceof String) {
                                // String으로 저장된 경우 Long으로 변환
                                return Long.valueOf((String) value);
                            }
                            throw new IllegalArgumentException("Unsupported memberId type: " + value.getClass());
                        },
                        ZSetOperations.TypedTuple::getScore))
                : Collections.emptyMap();
    }



    public Long getMemberRank(Long memberId) {
        // 내림차순에서 멤버의 순위를 가져옴
        Long rank = redisTemplateRank.opsForZSet().reverseRank("memberRank", memberId);
        return rank != null ? rank + 1 : null; // 순위는 0부터 시작하므로 1을 더해줌
    }

}
