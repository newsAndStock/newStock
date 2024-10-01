package com.ssafy.newstock.notification.repository;

import com.ssafy.newstock.notification.domain.Notification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification,Long> {

    List<Notification> findAllByReceiverId(Long memberId);
}
