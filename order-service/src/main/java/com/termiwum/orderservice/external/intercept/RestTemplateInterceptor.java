package com.termiwum.orderservice.external.intercept;

import java.io.IOException;

import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpRequest;
import org.springframework.http.client.ClientHttpRequestExecution;
import org.springframework.http.client.ClientHttpRequestInterceptor;
import org.springframework.http.client.ClientHttpResponse;

import com.termiwum.orderservice.service.TokenService;

@Configuration
public class RestTemplateInterceptor implements ClientHttpRequestInterceptor {

    private final TokenService tokenService;

    public RestTemplateInterceptor(TokenService tokenService) {
        this.tokenService = tokenService;
    }

    @Override
    public ClientHttpResponse intercept(HttpRequest request, byte[] body, ClientHttpRequestExecution execution)
            throws IOException {
        String token = tokenService.extractToken(); // Extract token

        if (token != null) {
            request.getHeaders().add("Authorization", "Bearer " + token);
        }

        return execution.execute(request, body);
    }
}