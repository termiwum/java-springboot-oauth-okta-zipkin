package com.termiwum.orderservice.external.intercept;

import org.springframework.context.annotation.Configuration;

import com.termiwum.orderservice.service.TokenService;

import feign.RequestInterceptor;
import feign.RequestTemplate;

@Configuration
public class OAuthRequestInterceptor implements RequestInterceptor {

        private final TokenService tokenService;

        public OAuthRequestInterceptor(TokenService tokenService) {
                this.tokenService = tokenService;
        }

        @Override
        public void apply(RequestTemplate template) {
                String token = tokenService.extractToken(); // Get token from TokenService

                if (token != null) {
                        template.header("Authorization", "Bearer " + token);
                }
        }
}
