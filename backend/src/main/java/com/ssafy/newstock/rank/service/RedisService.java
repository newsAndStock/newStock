package com.ssafy.newstock.rank.service;



import org.springframework.data.redis.core.RedisTemplate;

import org.springframework.data.redis.core.ZSetOperations;
import org.springframework.stereotype.Service;


import java.text.SimpleDateFormat;
import java.util.*;
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

    public void addMemberScore(Double roi, Integer score) {

        redisTemplateRank.opsForZSet().add("memberScore", roi, score);
    }

    public Map<Double, Integer> getAllRoiWithScores() {
        // ZSet에서 모든 수익률과 멤버 ID를 가져오기
        Set<ZSetOperations.TypedTuple<Object>> roiScores =
                redisTemplateRank.opsForZSet().reverseRangeWithScores("memberScore", 0, -1);

        Map<Double, Integer> resultMap= roiScores != null
                ? roiScores.stream()
                .collect(Collectors.toMap(
                        tuple -> {
                            Object value = tuple.getValue();
                            // value가 Long인 경우에만 Long으로 캐스팅
                            if (value instanceof Number) {
                                return ((Number) value).doubleValue();
                            } else {
                                throw new ClassCastException("Expected a Number but got " + value.getClass().getSimpleName());
                            }
                        },
                        tuple -> {
                            // score는 Integer로 변환
                            Integer score = tuple.getScore() != null ? ((Number) tuple.getScore()).intValue() : null;
                            return score;
                        },
                        (existing, replacement) -> existing, // 충돌 시 기존 값을 유지
                        LinkedHashMap::new // 입력 순서를 유지하는 LinkedHashMap 사용
                ))
                : Collections.emptyMap();

        return resultMap;
    }


    public void setRankTime(){
        // 현재 시간을 "yyyy-MM-dd" 형식으로 가져오기

        String currentDateTime = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());

        // 랭킹 저장 시간 기록
        redisTemplateRank.opsForValue().set("rankSaveTime", currentDateTime);
    }

    public String getRankTime() {
        // Redis에서 랭킹 저장 시간을 읽어오기
        String rankSaveTime = (String) redisTemplateRank.opsForValue().get("rankSaveTime");
        return rankSaveTime != null ? rankSaveTime : "시간 정보가 없습니다."; // 값이 없을 경우 메시지 반환
    }



    public Map<Long, Double> getAllMembersWithScores() {
        Set<ZSetOperations.TypedTuple<Object>> topMembersWithScores =
                redisTemplateRank.opsForZSet().reverseRangeWithScores("memberRank", 0, -1);

        Map<Long, Double> resultMap= topMembersWithScores != null
                ? topMembersWithScores.stream()
                .collect(Collectors.toMap(
                        tuple -> {
                            Object value = tuple.getValue();
                            // value가 Long인 경우에만 Long으로 캐스팅
                            if (value instanceof Number) {
                                return ((Number) value).longValue();
                            } else {
                                throw new ClassCastException("Expected a Number but got " + value.getClass().getSimpleName());
                            }
                        },
                        ZSetOperations.TypedTuple::getScore,
                        (existing, replacement) -> existing, // 충돌 시 기존 값을 유지
                        LinkedHashMap::new // 입력 순서를 유지하는 LinkedHashMap 사용
                ))
                : Collections.emptyMap();

        return resultMap;
    }




    public Integer getMemberRank(Long memberId) {
        // 내림차순에서 멤버의 순위를 가져옴
        Double roi = redisTemplateRank.opsForZSet().score("memberRank", memberId);
        if (roi == null) {
            return 0;
        }
        Double score=redisTemplateRank.opsForZSet().score("memberScore",roi);
        return score.intValue();
    }

}
