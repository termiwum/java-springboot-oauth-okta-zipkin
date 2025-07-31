package com.termiwum.cloudgateway.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import reactor.core.publisher.Mono;

import java.security.Principal;

import org.springframework.security.oauth2.client.ReactiveOAuth2AuthorizedClientService;
import org.springframework.security.oauth2.core.OAuth2AccessToken;
import org.springframework.web.bind.annotation.GetMapping;

@RestController
@RequestMapping("/authenticate")
public class AuthenticationController {

        private final ReactiveOAuth2AuthorizedClientService authorizedClientService;

        public AuthenticationController(ReactiveOAuth2AuthorizedClientService authorizedClientService) {
                this.authorizedClientService = authorizedClientService;
        }

        @GetMapping("/print-token")
        public Mono<String> printToken(Principal principal) {
                return authorizedClientService.loadAuthorizedClient("auth0", principal.getName())
                                .map(authorizedClient -> {
                                        OAuth2AccessToken accessToken = authorizedClient.getAccessToken();

                                        System.out.println("Access Token Value: " + accessToken.getTokenValue());
                                        System.out.println("Token Expiration: " + accessToken.getExpiresAt());
                                        System.out.println("Token Type: " + accessToken.getTokenType());

                                        return accessToken.getTokenValue();
                                })
                                .defaultIfEmpty("No token found for the user");
        }
}
