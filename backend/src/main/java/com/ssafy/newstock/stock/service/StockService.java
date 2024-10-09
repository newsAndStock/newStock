package com.ssafy.newstock.stock.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ssafy.newstock.common.util.WebClientUtil;
import com.ssafy.newstock.memberstocks.repository.MemberStocksRepository;
import com.ssafy.newstock.stock.controller.response.*;
import com.ssafy.newstock.stock.domain.StockInfo;
import com.ssafy.newstock.stock.repository.MinuteStockInfoRepository;
import com.ssafy.newstock.stock.repository.StockInfoRepository;
import com.ssafy.newstock.stock.repository.StockRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class StockService {
    private final StockInfoRepository stockInfoRepository;
    private final MinuteStockInfoRepository minuteStockInfoRepository;
    private final StockRepository stockRepository;
    private final MemberStocksRepository memberStocksRepository;
    private final WebClientUtil webClientUtil;

    private static final ObjectMapper objectMapper = new ObjectMapper();
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyyMMdd");
    private static final String NOT_AVAILABLE = "현재 제공하지 않습니다";

    private long currentPrice; // 현재가
    private long listedStockCount; // 상장주수
    private long netIncome; // 당기순이익
    private long totalAssets;  // 자산총계
    private long totalLiabilities;  // 부채총계

    public List<StockInfoResponse> getStockInfo(String stockCode, String period) {
        LocalDate currentDate = LocalDate.now();
        LocalDate startDate = switch (period) {
            case "day" -> currentDate.minusMonths(3);
            case "week" -> currentDate.minusYears(1);
            case "month" -> currentDate.minusYears(5);
            default -> throw new IllegalArgumentException("기간 잘못 입력");
        };

        List<StockInfo> stockInfoList = stockInfoRepository.findDataWithinRange(startDate.format(FORMATTER), stockCode, period);

        return stockInfoList.stream()
                .map(StockInfoResponse::from)
                .collect(Collectors.toList());
    }

    public List<MinuteStockInfoResponse> getDailyStockInfo(String stockCode) {
        return minuteStockInfoRepository.findByStockCode(stockCode)
                .stream()
                .map(MinuteStockInfoResponse::from)
                .collect(Collectors.toList());
    }

    public StockHoldingsResponse getMemberStockHoldings(Long memberId, String stockCode) {
        Long holdingsCount = getHoldingsByMemberAndStockCode(memberId, stockCode);
        return new StockHoldingsResponse(findNameByStockCode(stockCode), holdingsCount);
    }

    public String findNameByStockCode(String stockCode) {
        return stockRepository.findByStockCode(stockCode)
                .orElseThrow(() -> new IllegalArgumentException("잘못된 주식 코드입니다."))
                .getName();
    }

    public Long getHoldingsByMemberAndStockCode(Long memberId, String stockCode) {
        return memberStocksRepository
                .getHoldingsByMember_IdAndStockCode(memberId, stockCode)
                .orElse(0L);
    }

    public StockDetailResponse getStockDetail(String stockCode) throws Exception {
        var stockPriceInfoFuture = CompletableFuture.supplyAsync(() -> getStockPrice(stockCode));
        var stockBasicInfoFuture = CompletableFuture.supplyAsync(() -> getStockBasicInfo(stockCode));
        var incomeStatementFuture = CompletableFuture.supplyAsync(() -> getIncomeStatement(stockCode));
        var balanceSheetFuture = CompletableFuture.runAsync(() -> getBalanceSheet(stockCode));

        var dividendInfoFuture = stockPriceInfoFuture.thenCompose(
                stockPriceInfo -> CompletableFuture.supplyAsync(() -> getDividendInfo(stockCode))
        );

        var financialRatioFuture = CompletableFuture
                .allOf(stockBasicInfoFuture, incomeStatementFuture, stockPriceInfoFuture, balanceSheetFuture)
                .thenCompose(unused -> CompletableFuture.supplyAsync(() -> getFinancialRatio(stockCode)));

        var allFutures = CompletableFuture.allOf(
                stockPriceInfoFuture, stockBasicInfoFuture, dividendInfoFuture, financialRatioFuture, incomeStatementFuture, balanceSheetFuture
        );
        allFutures.get();

        var stockPriceInfo = stockPriceInfoFuture.get();
        var stockBasicInfo = stockBasicInfoFuture.get();
        var incomeStatement = incomeStatementFuture.get();
        var dividendInfo = dividendInfoFuture.get();
        var financialRatio = financialRatioFuture.get();

        return new StockDetailResponse(
                stockBasicInfo.get("marketIdCode"), stockBasicInfo.get("industryCodeName"), stockBasicInfo.get("listingDate"),
                stockBasicInfo.get("capital"), stockBasicInfo.get("listedStockCount"),
                incomeStatement.get("salesRevenue"), incomeStatement.get("netIncome"), stockPriceInfo.get("marketCap"),
                stockPriceInfo.get("previousClosePrice"), stockPriceInfo.get("highPrice250Days"), stockPriceInfo.get("lowPrice250Days"),
                stockPriceInfo.get("yearlyHighPrice"), stockPriceInfo.get("yearlyLowPrice"), dividendInfo.get("dividendAmount"),
                dividendInfo.get("dividendYield"), financialRatio.get("PER"), financialRatio.get("EPS"), financialRatio.get("PBR"),
                financialRatio.get("BPS"), financialRatio.get("ROE"), financialRatio.get("ROA")
        );
    }

    public Map<String, String> getStockBasicInfo(String stockCode) {
        String url = "/uapi/domestic-stock/v1/quotations/search-stock-info";
        Map<String, String> queryParams = Map.of("PRDT_TYPE_CD", "300", "PDNO", stockCode);
        Map<String, String> headers = Map.of("tr_id", "CTPF1002R", "custtype", "P");

        try {
            log.info("주식기본조회 API 호출: {}", stockCode);
            String response = webClientUtil.sendRequest(url, queryParams, headers);

            JsonNode node = objectMapper.readTree(response).path("output");
            listedStockCount = node.path("lstg_stqt").asLong();

            Map<String, String> resultMap = new HashMap<>();
            resultMap.put("marketIdCode", node.path("mket_id_cd").asText());
            resultMap.put("industryCodeName", node.path("std_idst_clsf_cd_name").asText());
            resultMap.put("listingDate", node.path("scts_mket_lstg_dt").asText());
            resultMap.put("capital", node.path("cpta").asText());
            resultMap.put("listedStockCount", String.valueOf(listedStockCount));

            return resultMap;
        } catch (Exception ex) {
            throw new RuntimeException("주식 기본 조회 API 호출 실패: " + stockCode, ex);
        }
    }

    public Map<String, String> getIncomeStatement(String stockCode) {
        String url = "/uapi/domestic-stock/v1/finance/income-statement";
        Map<String, String> queryParams = Map.of("fid_cond_mrkt_div_code", "J", "fid_input_iscd", stockCode, "fid_div_cls_code", "0");
        Map<String, String> headers = Map.of("tr_id", "FHKST66430200", "custtype", "P");

        try {
            log.info("손익계산서 API 호출: {}", stockCode);
            String response = webClientUtil.sendRequest(url, queryParams, headers);

            JsonNode node = objectMapper.readTree(response).path("output").get(1);
            netIncome = node.path("thtr_ntin").asLong();

            Map<String, String> resultMap = new HashMap<>();
            resultMap.put("salesRevenue", node.path("sale_account").asText());
            resultMap.put("netIncome", String.valueOf(netIncome));

            return resultMap;
        } catch (Exception ex) {
            log.error("손익계산서 API 호출 중 오류 발생 (stockCode: {}): {}", stockCode, ex.getMessage());

            netIncome = 0;
            Map<String, String> resultMap = new HashMap<>();
            resultMap.put("salesRevenue", NOT_AVAILABLE);
            resultMap.put("netIncome", NOT_AVAILABLE);

            return resultMap;
        }
    }

    public Map<String, String> getStockPrice(String stockCode) {
        String url = "/uapi/domestic-stock/v1/quotations/inquire-price";
        Map<String, String> queryParams = Map.of("FID_COND_MRKT_DIV_CODE", "J", "FID_INPUT_ISCD", stockCode);

        try {
            log.info("주식현재가시세 API 호출: {}", stockCode);
            String response = webClientUtil.sendRequest(url, queryParams, Map.of("tr_id", "FHKST01010100"));

            JsonNode node = objectMapper.readTree(response).path("output");

            currentPrice = node.path("stck_prpr").asLong();
            long marketCap = node.path("lstn_stcn").asLong() * currentPrice; // 시가총액 = 상장주식수 * 현재가

            Map<String, String> resultMap = new HashMap<>();
            resultMap.put("marketCap", String.valueOf(marketCap));
            resultMap.put("previousClosePrice", node.path("stck_oprc").asText());
            resultMap.put("highPrice250Days", node.path("d250_hgpr").asText());
            resultMap.put("lowPrice250Days", node.path("d250_lwpr").asText());
            resultMap.put("yearlyHighPrice", node.path("stck_dryy_hgpr").asText());
            resultMap.put("yearlyLowPrice", node.path("stck_dryy_lwpr").asText());

            return resultMap;
        } catch (Exception ex) {
            throw new RuntimeException("주식현재가시세 API 호출 실패: " + stockCode, ex);
        }
    }

    public Map<String, String> getDividendInfo(String stockCode) {
        String url = "/uapi/domestic-stock/v1/ksdinfo/dividend";
        Map<String, String> queryParams = Map.of(
                "CTS", "", "GB1", "1", "F_DT", "20230101", "T_DT", "20240101", "SHT_CD", stockCode, "HIGH_GB", "");
        Map<String, String> headers = Map.of("tr_id", "HHKDB669102C0", "custtype", "P");

        try {
            log.info("예탁원정보 API 호출: {}", stockCode);
            String response = webClientUtil.sendRequest(url, queryParams, headers);

            JsonNode node = objectMapper.readTree(response).path("output1").get(0);

            double dividendAmount = node.path("per_sto_divi_amt").asDouble();
            double dividendYield = (dividendAmount / currentPrice) * 100;

            Map<String, String> resultMap = new HashMap<>();
            resultMap.put("dividendAmount", String.valueOf(dividendAmount));
            resultMap.put("dividendYield", String.format("%.2f", dividendYield));

            return resultMap;
        } catch (Exception ex) {
            log.error("예탁원정보 API 호출 실패 (stockCode: {}): {}", stockCode, ex.getMessage());

            Map<String, String> resultMap = new HashMap<>();
            resultMap.put("dividendAmount", NOT_AVAILABLE);
            resultMap.put("dividendYield", NOT_AVAILABLE);

            return resultMap;
        }
    }

    public Map<String, String> getFinancialRatio(String stockCode) {
        String url = "/uapi/domestic-stock/v1/finance/financial-ratio";
        Map<String, String> queryParams = Map.of("fid_cond_mrkt_div_code", "J", "fid_input_iscd", stockCode, "fid_div_cls_code", "0");
        Map<String, String> headers = Map.of("tr_id", "FHKST66430300", "custtype", "P");

        try {
            log.info("국내주식 재무비율 API 호출: {}", stockCode);
            String response = webClientUtil.sendRequest(url, queryParams, headers);

            JsonNode node = objectMapper.readTree(response).path("output").get(1);

            double EPS = node.path("eps").asDouble();
            double PER = listedStockCount / EPS; // 발행주수 / EPS
            double BPS = node.path("bps").asDouble();
            double PBR = currentPrice / BPS; // 주가 / BPS
            double ROE = node.path("roe_val").asDouble(); // 자기자본 순이익율
            double ROA = (netIncome / (double) (totalAssets + totalLiabilities)) * 100;

            Map<String, String> resultMap = new HashMap<>();
            resultMap.put("PER", String.format("%.2f", PER));
            resultMap.put("EPS", String.format("%.2f", EPS));
            resultMap.put("PBR", String.format("%.2f", PBR));
            resultMap.put("BPS", String.format("%.2f", BPS));
            resultMap.put("ROE", String.format("%.2f", ROE));
            resultMap.put("ROA", String.format("%.2f", ROA));

            return resultMap;
        } catch (Exception ex) {
            log.error("국내주식 재무비율 API 호출 실패 (stockCode: {}): {}", stockCode, ex.getMessage());

            Map<String, String> resultMap = new HashMap<>();
            resultMap.put("PER", NOT_AVAILABLE);
            resultMap.put("EPS", NOT_AVAILABLE);
            resultMap.put("PBR", NOT_AVAILABLE);
            resultMap.put("BPS", NOT_AVAILABLE);
            resultMap.put("ROE", NOT_AVAILABLE);
            resultMap.put("ROA", NOT_AVAILABLE);

            return resultMap;
        }
    }

    public void getBalanceSheet(String stockCode) {
        String url = "/uapi/domestic-stock/v1/finance/balance-sheet";
        Map<String, String> queryParams = Map.of("fid_cond_mrkt_div_code", "J", "fid_input_iscd", stockCode, "fid_div_cls_code", "0");
        Map<String, String> headers = Map.of("tr_id", "FHKST66430100", "custtype", "P");

        try {
            log.info("국내주식 대차대조표 API 호출: {}", stockCode);
            String response = webClientUtil.sendRequest(url, queryParams, headers);

            JsonNode node = objectMapper.readTree(response).path("output").get(0);
            totalAssets = node.path("total_aset").asLong();
            totalLiabilities = node.path("total_lblt").asLong();
        } catch (Exception ex) {
            log.error("국내주식 대차대조표 API 호출 중 오류 발생 (stockCode: {}): {}", stockCode, ex.getMessage());

            totalAssets = 0;
            totalLiabilities = 0;
        }
    }

    public CurrentStockPriceResponse getInquirePrice(String stockCode) {
        String url = "/uapi/domestic-stock/v1/quotations/inquire-price";
        Map<String, String> queryParams = Map.of("FID_COND_MRKT_DIV_CODE", "J", "FID_INPUT_ISCD", stockCode);

        try {
            log.info("주식현재가시세 API 호출: {}", stockCode);

            String response = webClientUtil.sendRequest(url, queryParams, Map.of("tr_id", "FHKST01010100"));
            JsonNode node = objectMapper.readTree(response).path("output");

            String stckPrpr = node.path("stck_prpr").asText();
            String prdyVrss = node.path("prdy_vrss").asText();
            String prdyCtrt = node.path("prdy_ctrt").asText();

            return getInquireAskingPrice(stockCode, stckPrpr, prdyVrss, prdyCtrt);
        } catch (Exception ex) {
            throw new RuntimeException("주식현재가시세 API 호출 실패: " + stockCode, ex);
        }
    }

    public CurrentStockPriceResponse getInquireAskingPrice(String stockCode, String stckPrpr, String prdyVrss, String prdyCtrt) {
        String url = "/uapi/domestic-stock/v1/quotations/inquire-asking-price-exp-ccn";
        Map<String, String> queryParams = Map.of("FID_COND_MRKT_DIV_CODE", "J", "FID_INPUT_ISCD", stockCode);

        try {
            log.info("주식현재가 호가/예상체결 API 호출: {}", stockCode);

            String response = webClientUtil.sendRequest(url, queryParams, Map.of("tr_id", "FHKST01010200"));
            JsonNode node = objectMapper.readTree(response).path("output1");

            Map<String, String> askpMap = new LinkedHashMap<>();
            for (int i = 1; i <= 10; i++) {
                askpMap.put(node.path("askp" + i).asText(), node.path("askp_rsqn" + i).asText());
            }

            Map<String, String> bidpMap = new LinkedHashMap<>();
            for (int i = 1; i <= 10; i++) {
                bidpMap.put(node.path("bidp" + i).asText(), node.path("bidp_rsqn" + i).asText());
            }

            return new CurrentStockPriceResponse(stckPrpr, prdyVrss, prdyCtrt, askpMap, bidpMap);
        } catch (Exception ex) {
            throw new RuntimeException("주식현재가 호가/예상체결 API 호출 실패: " + stockCode, ex);
        }
    }
}
