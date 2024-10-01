package com.ssafy.newstock.scrap.repository;

import com.ssafy.newstock.scrap.domain.Scrap;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ScrapRepository extends JpaRepository<Scrap, Long> {
    List<Scrap> findByMemberId(Long memberId);
}
