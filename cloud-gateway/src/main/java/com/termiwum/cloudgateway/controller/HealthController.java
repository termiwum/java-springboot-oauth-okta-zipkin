package com.termiwum.cloudgateway.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/health")
public class HealthController {

    @GetMapping
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("timestamp", LocalDateTime.now());
        response.put("service", "API-GATEWAY");
        response.put("java_version", System.getProperty("java.version"));
        response.put("spring_boot_version", "3.5.4");
        response.put("message", "Cloud Gateway funcionando correctamente con Java 21 y Spring Boot 3.5.4");

        return ResponseEntity.ok(response);
    }
}
