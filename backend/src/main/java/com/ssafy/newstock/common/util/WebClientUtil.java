package com.ssafy.newstock.common.util;

import com.ssafy.newstock.kis.service.KisService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Map;

@Component
@RequiredArgsConstructor
public class WebClientUtil {
    @Value("${kis.prod-appkey}")
    private String appKey;

    @Value("${kis.prod-appsecret}")
    private String appSecret;

    private final WebClient webClient;
    private final KisService kisService;

    public String sendRequest(String path, Map<String, String> queryParams, Map<String, String> additionalHeaders) {
        UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromPath(path);
        queryParams.forEach(uriBuilder::queryParam);
        String uri = uriBuilder.build().toUriString();

        WebClient.RequestHeadersUriSpec<?> uriSpec = webClient.get();
        uriSpec.uri(uri)
                .header("authorization", "Bearer " + kisService.getToken())
                .header("appkey", appKey)
                .header("appsecret", appSecret)
                .header("tr_id", "FHKST03010100");

        if (additionalHeaders != null) {
            additionalHeaders.forEach(uriSpec::header);
        }

        return uriSpec.retrieve()
                .bodyToMono(String.class)
                .block();
    }
}
