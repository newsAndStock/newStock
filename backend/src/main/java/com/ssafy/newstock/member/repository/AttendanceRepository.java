package com.ssafy.newstock.member.repository;

import com.ssafy.newstock.member.domain.Attendance;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface AttendanceRepository extends JpaRepository<Attendance, Long> {
    List<Attendance> findAllByMemberId(Long memberId);
    boolean existsByMemberIdAndDate(Long memberId, LocalDate attendanceDate);
}
