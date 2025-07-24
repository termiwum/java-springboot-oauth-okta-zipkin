package com.termiwum.paymentservice.service;

import com.termiwum.paymentservice.model.PaymentRequest;
import com.termiwum.paymentservice.model.PaymentResponse;

public interface PaymentService {

    long doPayment(PaymentRequest request);

    PaymentResponse getDetailByOrderId(String orderId);
}
