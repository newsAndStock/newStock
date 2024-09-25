package com.ssafy.newstock.memberstocks.service;

import com.ssafy.newstock.memberstocks.domain.MemberStock;
import com.ssafy.newstock.memberstocks.repository.MemberStocksRepository;
import org.springframework.stereotype.Service;

@Service
public class MemberStocksService {

    private final MemberStocksRepository memberStocksRepository;

    public MemberStocksService(MemberStocksRepository memberStocksRepository){
        this.memberStocksRepository=memberStocksRepository;
    }

    public Long getHoldingsByMemberAndStockCode(Long memberId, String stockCode){

        if(memberStocksRepository.getHoldingsByMember_IdAndStockCode(memberId,stockCode).isPresent()){
            return memberStocksRepository.getHoldingsByMember_IdAndStockCode(memberId,stockCode).get();
        }
        return 0L;
    }

    public void sellComplete(Long memberId, String stockCode, long quantity, int price){
        if(memberStocksRepository.getMemberStockByMember_IdAndStockCode(memberId,stockCode).isEmpty())return;

        MemberStock memberStock=memberStocksRepository.getMemberStockByMember_IdAndStockCode(memberId,stockCode).get();

        float out=memberStock.getAveragePrice()*quantity;
        memberStock.updateTotalPrice(memberStock.getTotalPrice()-out);
        memberStock.sell(quantity);
        memberStocksRepository.save(memberStock);
    }



}
