package com.termiwum.orderservice.external.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.termiwum.orderservice.exception.CustomException;

import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;

@CircuitBreaker(name = "external", fallbackMethod = "fallback")
@FeignClient(name = "PRODUCT-SERVICE", path = "/products")
public interface ProductService {

    @PutMapping("/reduceQuantity/{id}")
    ResponseEntity<Void> reduceQuantity(@PathVariable("id") long productId, @RequestParam long quantity);

    default ResponseEntity<Void> fallback(Exception e) {
        throw new CustomException("Product Service Unavailable", "UNAVAILABLE", 500);
    }

}
