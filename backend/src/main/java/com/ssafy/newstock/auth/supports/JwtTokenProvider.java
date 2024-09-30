package com.ssafy.newstock.auth.supports;

import com.ssafy.newstock.auth.service.CustomUserDetailsService;
import com.ssafy.newstock.member.domain.Member;
import io.jsonwebtoken.*;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import static io.jsonwebtoken.SignatureAlgorithm.HS256;
import static org.springframework.http.HttpHeaders.AUTHORIZATION;

@Component
@RequiredArgsConstructor
public class JwtTokenProvider {
    private final CustomUserDetailsService customUserDetailsService;

    @Value("${jwt.secret-key}")
    private String secretKey;

    @Value("${jwt.refresh-key}")
    private String refreshKey;

    public String extractToken(HttpServletRequest request) {
        String header = request.getHeader(AUTHORIZATION);
        if (header == null || !header.startsWith("Bearer")) {
            return null;
        }
        return header.substring(7);
    }

    public String createAccessToken(Member member) {
        return createToken(member, 1000 * 60 * 60 * 24, secretKey);
    }

    public String createRefreshToken(Member member) {
        return createToken(member, 1000 * 60 * 60 * 24 * 7, refreshKey);
    }

    public String createToken(Member member, int expiration, String encodingKey) {
        Date now = new Date();
        return Jwts.builder()
                .setSubject(member.getId().toString())
                .setClaims(createClaims(member))
                .setIssuedAt(now)
                .setExpiration(new Date(now.getTime() + expiration))
                .signWith(HS256, encodingKey)
                .compact();
    }

    private Map<String, Object> createClaims(Member member) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("id", member.getId());
        claims.put("role", member.getRole());
        return claims;
    }

    public boolean validateAccessToken(String token) {
        try {
            Jwts.parser().setSigningKey(secretKey).parseClaimsJws(token);
            return true;
        } catch (ExpiredJwtException e) {
            throw new ExpiredJwtException(e.getHeader(), e.getClaims(), "토큰 만료");
        } catch (JwtException e) {
            throw new JwtException("유효하지 않은 토큰");
        }
    }

    public boolean validateRefreshToken(String token) {
        try {
            Jwts.parser().setSigningKey(refreshKey).parseClaimsJws(token);
            return true;
        } catch (JwtException e) {
            return false;
        }
    }

    public Long getMemberId(String token, String encodingKey) {
        String id = Jwts.parser()
                .setSigningKey(encodingKey)
                .parseClaimsJws(token)
                .getBody().get("id").toString();
        return Long.valueOf(id);
    }

    public Long getMemberIdFromAccessToken(String token) {
        return getMemberId(token, secretKey);
    }

    public Long getMemberIdFromRefreshToken(String token) {
        return getMemberId(token, refreshKey);
    }

    public Authentication getAuthentication(String token) {
        String userId = String.valueOf(getMemberId(token, secretKey));
        UserDetails userDetails = customUserDetailsService.loadUserByUsername(userId);
        return new UsernamePasswordAuthenticationToken(userDetails, userDetails.getPassword(), userDetails.getAuthorities());
    }
}
