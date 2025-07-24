package com.termiwum.cloudgateway.model;

import java.util.Collection;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class AuthenticationResponse {

    private String userId;
    private String accesToken;
    private String refreshToken;
    private long expiresAt;
    private Collection<String> authorityList;
    private Collection<String> scopes;

}
