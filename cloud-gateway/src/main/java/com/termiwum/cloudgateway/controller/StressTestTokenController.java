package com.termiwum.cloudgateway.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.reactive.function.client.WebClient;

import com.termiwum.cloudgateway.model.AuthenticationResponse;

import reactor.core.publisher.Mono;

import java.util.Map;

/**
 * Controlador para obtener tokens OAuth2 en pruebas de estrés
 * Solo activo en profile stress-testing
 */
@RestController
@RequestMapping("/token")
@Profile("stress-testing")
public class StressTestTokenController {

    @Value("${spring.security.oauth2.client.registration.auth0.client-id}")
    private String clientId;

    @Value("${spring.security.oauth2.client.registration.auth0.client-secret}")
    private String clientSecret;

    @Value("${spring.security.oauth2.client.provider.auth0.issuer-uri}")
    private String issuerUri;

    @Value("${auth0.audience}")
    private String audience;

    private final WebClient webClient;

    public StressTestTokenController() {
        this.webClient = WebClient.builder().build();
    }

    /**
     * Endpoint para obtener token OAuth2 usando Client Credentials
     * Solo para pruebas de estrés
     */
    @PostMapping("/client-credentials")
    public Mono<ResponseEntity<AuthenticationResponse>> getClientCredentialsToken() {

        String tokenUrl = issuerUri + "/oauth/token";

        String body = "grant_type=client_credentials" +
                "&client_id=" + clientId +
                "&client_secret=" + clientSecret +
                "&audience=" + audience;

        return webClient.post()
                .uri(tokenUrl)
                .header("Content-Type", "application/x-www-form-urlencoded")
                .bodyValue(body)
                .retrieve()
                .bodyToMono(Map.class)
                .map(response -> {
                    AuthenticationResponse authResponse = AuthenticationResponse.builder()
                            .accesToken((String) response.get("access_token"))
                            .expiresAt(System.currentTimeMillis() + ((Integer) response.get("expires_in")) * 1000L)
                            .build();

                    return ResponseEntity.ok(authResponse);
                })
                .onErrorReturn(ResponseEntity.status(HttpStatus.UNAUTHORIZED).build());
    }

    /**
     * Endpoint simplificado para pruebas básicas
     */
    @PostMapping("/test")
    public Mono<ResponseEntity<String>> getTestToken() {
        return getClientCredentialsToken()
                .map(response -> {
                    if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                        return ResponseEntity.ok(response.getBody().getAccesToken());
                    }
                    return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Failed to get token");
                });
    }
}
