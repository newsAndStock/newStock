package com.ssafy.newstock.stock.controller.response;

import com.ssafy.newstock.stock.domain.FavoriteStock;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class MemberFavoriteStockResponse {
    private Long memberId;
    private String email;
    private String nickname;
    private List<FavoriteStockResponse> stocks;

}
