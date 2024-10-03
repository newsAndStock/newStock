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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class RankService {

    private final MemberStocksService memberStocksService;
    private final KisService kisService;
    private final MemberService memberService;
    private final RedisService redisService;

    @Scheduled(cron = "0 0 17 * * ?") // 매일 17:00에 실행
    public void makeRank(){
        List<Member> members=memberService.findAllMember();
        for(Member member:members){
            double ROI=memberROI(member.getId());
            redisService.addMemberRank(member.getId(),ROI);
        }
        redisService.setRankTime();
    }

    private double memberROI(Long memberId){
        long oldPrice=0L;
        long newPrice=0L;
        List<MemberStock> memberStocks=memberStocksService.findByMember_Id(memberId);
        for(MemberStock memberStock:memberStocks){
            String stockCode=memberStock.getStockCode();
            int currentPrice=Integer.parseInt(kisService.getCurrentStockPrice(stockCode));
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
        Map<String,Double> result=new HashMap<>();
        for (Map.Entry<Long, Double> entry : ranks.entrySet()) {
            Long memberId = entry.getKey();
            Double score = entry.getValue();
            String memberNickname=memberService.findById(memberId).getNickname();
            result.put(memberNickname,score);

        }

        return new RankResponse(redisService.getRankTime(), result);
    }

    public Long getRank(Long memberId){
        return redisService.getMemberRank(memberId);
    }


}
