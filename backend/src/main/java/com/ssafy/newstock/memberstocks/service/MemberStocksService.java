package com.ssafy.newstock.memberstocks.service;

import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.service.MemberService;
import com.ssafy.newstock.memberstocks.domain.MemberStock;
import com.ssafy.newstock.memberstocks.repository.MemberStocksRepository;
import org.springframework.stereotype.Service;

@Service
public class MemberStocksService {

    private final MemberStocksRepository memberStocksRepository;
    private final MemberService memberService;

    public MemberStocksService(MemberStocksRepository memberStocksRepository, MemberService memberService){
        this.memberStocksRepository=memberStocksRepository;
        this.memberService = memberService;
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

        double out=memberStock.getAveragePrice()*quantity;
        memberStock.updateTotalPrice(memberStock.getTotalPrice()-out);
        memberStock.sell(quantity);
        memberStocksRepository.save(memberStock);
    }

    public void buyComplete(Long memberId, String stockCode, long quantity, int price){
        MemberStock memberStock;
        Member member=memberService.findById(memberId);
        if(memberStocksRepository.findByMember_IdAndStockCode(memberId,stockCode).isPresent()){
            memberStock=memberStocksRepository.findByMember_IdAndStockCode(memberId,stockCode).get();
        }else{
            memberStock=MemberStock.builder()
                    .stockCode(stockCode)
                    .member(member)
                    .build();
        }
        updateMemberStock(memberStock,quantity);
        memberStocksRepository.save(memberStock);

    }

    private void updateMemberStock(MemberStock memberStock, long quantity){
        double in=memberStock.getAveragePrice()*quantity;
        memberStock.updateTotalPrice(memberStock.getTotalPrice()+in);
        memberStock.buy(quantity);
        double totalPrice=memberStock.getTotalPrice();
        long holdings=memberStock.getHoldings();
        float averagePrice= (float) (totalPrice/holdings);
        memberStock.updateAveragePrice(averagePrice);
    }



}
