package com.ssafy.newstock.rank.service;

import com.ssafy.newstock.kis.service.KisService;
import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.service.MemberService;
import com.ssafy.newstock.memberstocks.domain.MemberStock;
import com.ssafy.newstock.memberstocks.service.MemberStocksService;
import com.ssafy.newstock.rank.controller.response.RankResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RankService {

    private final MemberStocksService memberStocksService;
    private final KisService kisService;
    private final MemberService memberService;
    private final RedisService redisService;
    private final RedisTemplate<String, Object> redisTemplateRank;

    @Scheduled(cron = "0 0 10-16 * * ?")
    public void makeRankSchedule(){
        makeRank();
        dealSameScore();
    }

    public void makeRank(){
        List<Member> members=memberService.findAllMember();
        redisTemplateRank.delete("memberRank");

        // 1. 필요한 모든 주식 코드를 수집 (중복 제거)
        Set<String> allStockCodes = members.stream()
                .flatMap(member -> memberStocksService.findByMember_Id(member.getId()).stream())
                .map(MemberStock::getStockCode)
                .collect(Collectors.toSet());

        // 2. 각 주식의 현재가를 한번씩만 조회하여 캐싱
        Map<String, Integer> currentPriceCache = new HashMap<>();
        for (String stockCode : allStockCodes) {
            try {
                currentPriceCache.put(stockCode, Integer.parseInt(kisService.getCurrentStockPrice(stockCode)));
            } catch (NumberFormatException e) {
                currentPriceCache.put(stockCode, 0);
            }
        }

        for(Member member:members){
            if(memberStocksService.getMemberStocks(member.getId()).isEmpty())continue;
            double ROI=memberROI(member.getId(),currentPriceCache);
            redisService.addMemberRank(member.getId(),ROI);
        }
        redisService.setRankTime();
    }

    public void dealSameScore(){
        redisTemplateRank.delete("memberScore");
        Map<Long,Double> ranks=redisService.getAllMembersWithScores();
        Map<Double,Integer> scores=new LinkedHashMap<>();
        for(Map.Entry<Long,Double> entry:ranks.entrySet()){
            scores.put(entry.getValue(),scores.getOrDefault(entry.getValue(),0) + 1);
        }
        int start=1;
        for(Map.Entry<Double,Integer> entry:scores.entrySet()){
            redisService.addMemberScore(entry.getKey(),start);
            start+=entry.getValue();
        }
    }

    private double memberROI(Long memberId, Map<String, Integer> currentPriceCache){
        long oldPrice=0L;
        long newPrice=0L;
        List<MemberStock> memberStocks=memberStocksService.findByMember_Id(memberId);
        for(MemberStock memberStock:memberStocks){
            String stockCode=memberStock.getStockCode();
            int currentPrice = currentPriceCache.getOrDefault(stockCode, 0);

            newPrice += (long) currentPrice * memberStock.getHoldings();
            oldPrice += memberStock.getAveragePrice() * memberStock.getHoldings();

            newPrice+=currentPrice*memberStock.getHoldings();
            oldPrice+=memberStock.getAveragePrice()*memberStock.getHoldings();
        }

        if(oldPrice==0){
            return 0;
        }
        double ROI= (double)(newPrice-oldPrice)/oldPrice*100;

        BigDecimal bd = new BigDecimal(ROI);
        bd = bd.setScale(1, RoundingMode.HALF_UP); // 둘째 자리에서 반올림

        return bd.doubleValue();
    }

    public RankResponse allRank(){
        Map<Long,Double> ranks=redisService.getAllMembersWithScores();
        Map<Double,Integer> scores=redisService.getAllRoiWithScores();
        Map<String,Double> result=new LinkedHashMap<>();
        for (Map.Entry<Long, Double> entry : ranks.entrySet()) {
            Long memberId = entry.getKey();
            Double score = entry.getValue();
            Integer memberScore=scores.get(score);

            String memberNickname=memberService.findById(memberId).getNickname();
            String key=memberScore+":"+memberNickname;
            result.put(key,score);
        }


        return new RankResponse(redisService.getRankTime(), result);
    }




}
