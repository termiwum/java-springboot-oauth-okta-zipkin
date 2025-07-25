package com.termiwum.cloudgateway.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.termiwum.cloudgateway.model.AuthenticationResponse;

import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
// import org.springframework.security.core.GrantedAuthority;
// import org.springframework.security.core.annotation.AuthenticationPrincipal;
// import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
// import org.springframework.security.oauth2.client.annotation.RegisteredOAuth2AuthorizedClient;
// import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@RestController
@RequestMapping("/authenticate")
public class AuthenticationController {

        // @GetMapping("/login")
        // public ResponseEntity<AuthenticationResponse> login(
        // @AuthenticationPrincipal OidcUser oidcUser,
        // Model model,
        // @RegisteredOAuth2AuthorizedClient("okta") OAuth2AuthorizedClient client) {
        // AuthenticationResponse response = AuthenticationResponse.builder()
        // .userId(oidcUser.getEmail())
        // .accesToken(client.getAccessToken().getTokenValue())
        // .refreshToken(client.getRefreshToken().getTokenValue())
        // .expiresAt(client.getAccessToken().getExpiresAt().getEpochSecond())
        // .authorityList(oidcUser.getAuthorities().stream()
        // .map(GrantedAuthority::getAuthority)
        // .collect(Collectors.toList()))
        // .scopes(client.getAccessToken().getScopes().stream()
        // .collect(Collectors.toList()))
        // .build();
        // return new ResponseEntity<>(response, HttpStatus.OK);
        // }

}
