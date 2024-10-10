package com.ssafy.newstock.keyword.repository;

import com.ssafy.newstock.keyword.domain.PopularWord;
import io.lettuce.core.dynamic.annotation.Param;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface KeyWordRepository extends JpaRepository<PopularWord,Long> {

    @Query("SELECT DISTINCT pw.word FROM PopularWord pw WHERE pw.date = :date ORDER BY pw.count DESC")
    List<String> findTop10DistinctWordsByDateOrderByCountDesc(@Param("date") String date);
}
