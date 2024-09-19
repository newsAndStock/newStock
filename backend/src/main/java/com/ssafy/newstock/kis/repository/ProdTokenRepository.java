package com.ssafy.newstock.kis.repository;

import com.ssafy.newstock.kis.domain.ProdToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface ProdTokenRepository extends JpaRepository<ProdToken,Long> {

    @Query("SELECT p FROM ProdToken p ORDER BY p.createdAt DESC")
    Optional<ProdToken> findLatest();
}
