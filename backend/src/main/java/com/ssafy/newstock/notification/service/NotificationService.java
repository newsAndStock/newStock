package com.ssafy.newstock.notification.service;

import com.ssafy.newstock.notification.controller.response.NotificationResponse;
import com.ssafy.newstock.notification.domain.Notification;
import com.ssafy.newstock.notification.repository.EmitterRepository;
import com.ssafy.newstock.notification.repository.EmitterRepositoryImpl;
import com.ssafy.newstock.notification.repository.NotificationRepository;
import com.ssafy.newstock.trading.domain.OrderType;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final EmitterRepository emitterRepository = new EmitterRepositoryImpl();
    private final NotificationRepository notificationRepository;

    private static final Long DEFAULT_TIMEOUT = 60L * 1000 * 60;

    public SseEmitter subscribe(Long memberId, String lastEventId) {
        String emitterId = memberId + "_" + System.currentTimeMillis();
        SseEmitter emitter = emitterRepository.save(emitterId, new SseEmitter(DEFAULT_TIMEOUT));

        emitter.onCompletion(() -> emitterRepository.deleteById(emitterId));
        emitter.onTimeout(() -> emitterRepository.deleteById(emitterId));

        sendToClient(emitter, emitterId, "EventStream Created. [memberId=" + memberId + "]");

        if (!lastEventId.isEmpty()) {
            Map<String, Object> events = emitterRepository.findAllEventCacheStartWithByMemberId(String.valueOf(memberId));
            events.entrySet().stream()
                    .filter(entry -> lastEventId.compareTo(entry.getKey()) < 0)
                    .forEach(entry -> sendToClient(emitter, entry.getKey(), entry.getValue()));
        }

        return emitter;
    }

    @Transactional
    public void send(Long receiverId, String stockCode, Long quantity, OrderType orderType, Integer price) {
        Notification notification = notificationRepository.save(createNotification(receiverId, stockCode, quantity,orderType,price));

        NotificationResponse notificationResponse=new NotificationResponse(notification);
        Map<String, SseEmitter> sseEmitters = emitterRepository.findAllEmitterStartWithByMemberId(receiverId+"");
        sseEmitters.forEach(
                (key, emitter) -> {
                    emitterRepository.saveEventCache(key, notification);
                    sendToClient(emitter, key, notificationResponse);
                }
        );
    }

    private void sendToClient(SseEmitter emitter, String emitterId, Object data) {
        try {
            emitter.send(SseEmitter.event()
                    .id(emitterId)
                    .data(data));
        } catch (IOException exception) {
            emitterRepository.deleteById(emitterId);
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Unhandled server error");
        }
    }

    private Notification createNotification(Long receiverId, String stockName, Long quantity, OrderType orderType, Integer price){
        return Notification.builder()
                .receiverId(receiverId)
                .stockName(stockName)
                .quantity(quantity)
                .orderType(orderType)
                .price(price)
                .build();
    }

    public List<NotificationResponse> getAllNotification(Long receiverId){
        List<Notification> notifications=notificationRepository.findAllByReceiverId(receiverId);
        List<NotificationResponse> notificationResponses=new ArrayList<>();
        for(Notification notification:notifications){
            NotificationResponse notificationResponse=new NotificationResponse(notification);
            notificationResponses.add(notificationResponse);
        }

        return notificationResponses;
    }
}
