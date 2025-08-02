package com.termiwum.cloudgateway.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;
import org.springframework.security.config.web.server.ServerHttpSecurity;
import org.springframework.security.web.server.SecurityWebFilterChain;

/**
 * Configuración de seguridad para pruebas de estrés
 * MANTIENE OAuth2 activo pero permite endpoints específicos para testing
 * NUNCA deshabilita la seguridad completamente
 */
@Configuration
@EnableWebFluxSecurity
@Profile("stress-testing")
public class StressTestingSecurityConfig {

    @Bean
    public SecurityWebFilterChain stressTestingFilterChain(ServerHttpSecurity http) throws Exception {
        http
                .authorizeExchange(authz -> authz
                        // Endpoints públicos específicos para testing (solo health y token)
                        .pathMatchers("/health/**", "/actuator/health", "/token/**").permitAll()
                        // TODO LO DEMÁS REQUIERE AUTENTICACIÓN (COMO DEBE SER)
                        .anyExchange().authenticated())
                .csrf(csrf -> csrf.disable()) // Deshabilitar CSRF para APIs
                // MANTENER OAuth2 ACTIVO - CRÍTICO PARA PRODUCCIÓN
                .oauth2ResourceServer(oauth2 -> oauth2
                        .jwt(jwt -> jwt.jwtAuthenticationConverter(createJwtConverter())));

        return http.build();
    }

    // Converter básico para JWT (simplificado para testing)
    private org.springframework.security.oauth2.server.resource.authentication.ReactiveJwtAuthenticationConverterAdapter createJwtConverter() {
        var converter = new org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter();
        return new org.springframework.security.oauth2.server.resource.authentication.ReactiveJwtAuthenticationConverterAdapter(
                converter);
    }
}
