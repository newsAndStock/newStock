package com.ssafy.newstock.kis.repository;


import com.ssafy.newstock.kis.domain.ProdToken2;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface ProdTokenRepository2 extends JpaRepository<ProdToken2,Long> {

    @Query(value = "SELECT * FROM prod_token2 ORDER BY created_at DESC LIMIT 1", nativeQuery = true)
    Optional<ProdToken2> findLatest();
}
