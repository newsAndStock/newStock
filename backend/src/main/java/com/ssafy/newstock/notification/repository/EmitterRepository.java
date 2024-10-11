package com.ssafy.newstock.notification.repository;

import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.Map;

public interface EmitterRepository {
    SseEmitter save(String emitterId, SseEmitter sseEmitter);
    void saveEventCache(String emitterId, Object event);
    
    Map<String, SseEmitter> findAllEmitterStartWithByMemberId(String memberId);
    Map<String,Object> findAllEventCacheStartWithByMemberId(String memberId);
    
    void deleteById(String emitterId);

    void deleteAllEmitterStartWithId(String memberId);

    void deleteAllEventCacheStartWithId(String memberId);
}