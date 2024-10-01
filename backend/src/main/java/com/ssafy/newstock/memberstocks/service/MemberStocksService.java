package com.ssafy.newstock.memberstocks.service;

import com.ssafy.newstock.kis.service.KisService;
import com.ssafy.newstock.member.domain.Member;
import com.ssafy.newstock.member.service.MemberService;
import com.ssafy.newstock.memberstocks.controller.response.AssetInfoResponse;
import com.ssafy.newstock.memberstocks.controller.response.MemberStockResponse;
import com.ssafy.newstock.memberstocks.domain.MemberStock;
import com.ssafy.newstock.memberstocks.repository.MemberStocksRepository;
import com.ssafy.newstock.stock.service.StockService;
import org.springframework.stereotype.Service;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;

@Service
public class MemberStocksService {

    private final MemberStocksRepository memberStocksRepository;
    private final MemberService memberService;
    private final KisService kisService;
    private final StockService stockService;

    public MemberStocksService(MemberStocksRepository memberStocksRepository, MemberService memberService,KisService kisService, StockService stockService){
        this.memberStocksRepository=memberStocksRepository;
        this.memberService = memberService;
        this.kisService=kisService;
        this.stockService=stockService;
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

        long out=memberStock.getAveragePrice()*quantity;
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
        updateMemberStock(memberStock,quantity,price);
        memberStocksRepository.save(memberStock);

    }

    private void updateMemberStock(MemberStock memberStock, long quantity,int price){
        long in=price*quantity;
        memberStock.updateTotalPrice(memberStock.getTotalPrice()+in);
        memberStock.buy(quantity);
        long totalPrice=memberStock.getTotalPrice();
        long holdings=memberStock.getHoldings();
        long averagePrice= totalPrice/holdings;
        memberStock.updateAveragePrice(averagePrice);
    }

    public AssetInfoResponse getMemberAssetInfo(Long memberId){
        Long deposit=memberService.findById(memberId).getDeposit();
        Long totalPrice=0L;
        long oldPrice=0L;
        long newPrice=0L;
        List<MemberStock> memberStocks=memberStocksRepository.findByMember_Id(memberId);
        for(MemberStock memberStock:memberStocks){
            String stockCode=memberStock.getStockCode();
            int currentPrice=Integer.parseInt(kisService.getCurrentStockPrice(stockCode));
            newPrice+=currentPrice*memberStock.getHoldings();
            oldPrice+=memberStock.getAveragePrice()*memberStock.getHoldings();
        }
        long profitAndLoss=newPrice-oldPrice;
        double ROI= (double)(newPrice-oldPrice)/oldPrice*100;
        DecimalFormat df = new DecimalFormat("0.0");
        String formattedROI = df.format(ROI);
        totalPrice=deposit+newPrice;
        return new AssetInfoResponse(totalPrice,deposit,profitAndLoss,formattedROI);
    }

    public List<MemberStockResponse> getMemberStocks(Long memberId){
        List<MemberStock> memberStocks=memberStocksRepository.findByMember_Id(memberId);
        List<MemberStockResponse> memberStockResponses=new ArrayList<>();
        for(MemberStock memberStock:memberStocks){
            Long currentPrice=Long.parseLong(kisService.getCurrentStockPrice(memberStock.getStockCode()));
            MemberStockResponse memberStockResponse=MemberStockResponse.builder()
                    .name(stockService.findNameByStockCode(memberStock.getStockCode()))
                    .currentPrice(currentPrice)
                    .userPrice(memberStock.getAveragePrice())
                    .quantity(memberStock.getHoldings())
                    .profitAndLoss(calculateProfitAndLoss(currentPrice,memberStock.getAveragePrice(),memberStock.getHoldings()))
                    .build();

            memberStockResponses.add(memberStockResponse);
        }

        return memberStockResponses;
    }

    private Long calculateProfitAndLoss(Long currentPrice, Long userPrice, Long quantity){
        return (currentPrice-userPrice)*quantity;
    }
}
