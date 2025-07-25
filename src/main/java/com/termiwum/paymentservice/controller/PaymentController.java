package com.termiwum.paymentservice.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.termiwum.paymentservice.model.PaymentRequest;
import com.termiwum.paymentservice.model.PaymentResponse;
import com.termiwum.paymentservice.service.PaymentService;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@RestController
@RequestMapping("/payments")
public class PaymentController {

    @Autowired
    private PaymentService paymentService;

    @PostMapping
    public ResponseEntity<Long> doPayment(@RequestBody PaymentRequest request) {
        return new ResponseEntity<>(
                paymentService.doPayment(request),
                HttpStatus.CREATED);
    }

    @GetMapping("/order/{orderId}")
    public ResponseEntity<PaymentResponse> getDetailsByOrderId(@PathVariable String orderId) {
        PaymentResponse paymentResponse = paymentService.getDetailByOrderId(orderId);
        return new ResponseEntity<>(paymentResponse, HttpStatus.OK);
    }

}
