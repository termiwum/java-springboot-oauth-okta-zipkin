package com.termiwum.cloudgateway.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/token")
public class TokenController {

    @Value("${spring.security.oauth2.client.provider.auth0.issuer-uri}")
    private String issuerUri;

    @Value("${spring.security.oauth2.client.registration.auth0.client-id}")
    private String clientId;

    @Value("${spring.security.oauth2.client.registration.auth0.client-secret}")
    private String clientSecret;

    @Value("${auth0.audience}")
    private String audience;

    private final WebClient webClient;

    public TokenController() {
        this.webClient = WebClient.builder().build();
    }

    @PostMapping("/authenticate")
    public Mono<ResponseEntity<Map<String, Object>>> authenticate(@RequestBody Map<String, String> credentials) {

        String username = credentials.get("username");
        String password = credentials.get("password");

        if (username == null || password == null) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", "Username and password are required");
            return Mono.just(ResponseEntity.badRequest().body(error));
        }

        // Construir el cuerpo de la petición para Auth0
        Map<String, String> tokenRequest = new HashMap<>();
        tokenRequest.put("grant_type", "password");
        tokenRequest.put("username", username);
        tokenRequest.put("password", password);
        tokenRequest.put("audience", audience);
        tokenRequest.put("client_id", clientId);
        tokenRequest.put("client_secret", clientSecret);
        tokenRequest.put("scope", "openid profile email");

        String tokenUrl = issuerUri + "/oauth/token";

        return webClient.post()
                .uri(tokenUrl)
                .header("Content-Type", "application/json")
                .body(BodyInserters.fromValue(tokenRequest))
                .retrieve()
                .bodyToMono(Map.class)
                .map(response -> {
                    Map<String, Object> result = new HashMap<>();
                    result.put("access_token", response.get("access_token"));
                    result.put("token_type", response.get("token_type"));
                    result.put("expires_in", response.get("expires_in"));
                    result.put("status", "success");
                    return ResponseEntity.ok(result);
                })
                .onErrorResume(error -> {
                    Map<String, Object> errorResponse = new HashMap<>();
                    errorResponse.put("error", "Authentication failed");
                    errorResponse.put("message", error.getMessage());
                    errorResponse.put("status", "error");
                    return Mono.just(ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(errorResponse));
                });
    }

    @GetMapping("/health")
    public Mono<ResponseEntity<Map<String, Object>>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "TOKEN-CONTROLLER");
        response.put("message", "Token controller is working");
        return Mono.just(ResponseEntity.ok(response));
    }
}
