package com.ssafy.newstock.keyword.repository;

import com.ssafy.newstock.keyword.domain.PopularWord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface KeyWordRepository extends JpaRepository<PopularWord,Long> {

    List<PopularWord> findTop10ByDateOrderByCountDesc(String date);
}
