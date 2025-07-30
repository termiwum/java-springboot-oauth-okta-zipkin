package com.termiwum.orderservice.controller;

import com.termiwum.orderservice.model.OrderRequest;
import com.termiwum.orderservice.model.OrderResponse;
import com.termiwum.orderservice.service.OrderService;

import lombok.extern.log4j.Log4j2;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.access.prepost.PreAuthorize;

@RestController
@RequestMapping("/orders")
@Log4j2
public class OrderController {

    @Autowired
    private OrderService orderService;

    @PreAuthorize("hasAuthority('Customer')")
    @PostMapping("placeOrder")
    public ResponseEntity<Long> placeOrder(@RequestBody OrderRequest orderRequest) {
        log.debug("Received placeOrder request: {}", orderRequest);
        long orderId = orderService.placeOrder(orderRequest);
        log.info("Order placed with ID: {}", orderId);
        log.debug("Returning response with orderId: {}", orderId);
        return new ResponseEntity<>(orderId, HttpStatus.OK);
    }

    @PreAuthorize("hasAuthority('Admin') || hasAuthority('Customer')")
    @GetMapping("/{orderId}")
    public ResponseEntity<OrderResponse> getOrderDetails(@PathVariable long orderId) {
        log.debug("Received getOrderDetails request for orderId: {}", orderId);
        OrderResponse orderResponse = orderService.getOrderDetails(orderId);
        log.debug("Returning response: {}", orderResponse);
        return new ResponseEntity<>(orderResponse, HttpStatus.OK);
    }

}
