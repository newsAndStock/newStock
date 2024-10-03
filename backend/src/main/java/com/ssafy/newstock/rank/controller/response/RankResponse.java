package com.ssafy.newstock.rank.controller.response;

import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.Map;

@Getter
@NoArgsConstructor
public class RankResponse {

    private String rankSaveTime;
    private Map<String,Double> ranking;

    public RankResponse(String rankSaveTime,Map<String,Double> ranking){
        this.rankSaveTime=rankSaveTime;
        this.ranking=ranking;
    }
}
