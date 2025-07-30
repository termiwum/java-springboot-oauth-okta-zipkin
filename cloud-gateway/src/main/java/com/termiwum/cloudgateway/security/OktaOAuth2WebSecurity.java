package com.termiwum.cloudgateway.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;
import org.springframework.security.config.web.server.ServerHttpSecurity;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.server.resource.authentication.ReactiveJwtAuthenticationConverter;
import org.springframework.security.web.server.SecurityWebFilterChain;

import reactor.core.publisher.Flux;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Configuration
@EnableWebFluxSecurity
public class OktaOAuth2WebSecurity {

        private static final Logger log = LoggerFactory.getLogger(OktaOAuth2WebSecurity.class);

        @Bean
        public ReactiveJwtAuthenticationConverter jwtAuthenticationConverter() {
                ReactiveJwtAuthenticationConverter converter = new ReactiveJwtAuthenticationConverter();
                converter.setJwtGrantedAuthoritiesConverter(jwt -> {
                        Object groups = jwt.getClaims().get("groups");
                        if (groups instanceof java.util.List) {
                                java.util.List<?> groupList = (java.util.List<?>) groups;
                                var authorities = groupList.stream()
                                                .map(String::valueOf)
                                                .map(SimpleGrantedAuthority::new)
                                                .toList();
                                log.info("Authorities extraídas del JWT: {}", authorities);
                                return Flux.fromIterable(authorities);
                        }
                        log.warn("No se encontraron authorities en el claim 'groups'. Claims: {}", jwt.getClaims());
                        return Flux.empty();
                });
                return converter;
        }

        @Bean
        public SecurityWebFilterChain securityFilterChain(ServerHttpSecurity http) {
                http
                                .csrf().disable()
                                .authorizeExchange()
                                .anyExchange().authenticated()
                                .and()
                                .oauth2ResourceServer()
                                .jwt()
                                .jwtAuthenticationConverter(jwtAuthenticationConverter());
                return http.build();
        }
}