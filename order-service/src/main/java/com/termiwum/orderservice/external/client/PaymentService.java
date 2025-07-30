package com.termiwum.orderservice.external.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import com.termiwum.orderservice.exception.CustomException;
import com.termiwum.orderservice.external.request.PaymentRequest;

import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;

@CircuitBreaker(name = "external", fallbackMethod = "fallback")
@FeignClient(name = "PAYMENT-SERVICE", path = "/payments")
public interface PaymentService {

    @PostMapping
    public ResponseEntity<Long> doPayment(@RequestBody PaymentRequest paymentRequest);

    default ResponseEntity<Void> fallback(Exception e) {
        throw new CustomException("Payment Service Unavailable", "UNAVAILABLE", 500);
    }
}
