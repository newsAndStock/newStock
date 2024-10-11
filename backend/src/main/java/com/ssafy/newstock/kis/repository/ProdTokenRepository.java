package com.ssafy.newstock.kis.repository;

import com.ssafy.newstock.kis.domain.ProdToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface ProdTokenRepository extends JpaRepository<ProdToken,Long> {

    @Query(value = "SELECT * FROM prod_token ORDER BY created_at DESC LIMIT 1", nativeQuery = true)
    Optional<ProdToken> findLatest();
}
