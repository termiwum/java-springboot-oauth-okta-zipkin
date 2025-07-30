package com.termiwum.paymentservice.service;

import java.time.Instant;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.termiwum.paymentservice.entity.TransactionDetails;
import com.termiwum.paymentservice.model.PaymentMode;
import com.termiwum.paymentservice.model.PaymentRequest;
import com.termiwum.paymentservice.model.PaymentResponse;
import com.termiwum.paymentservice.repository.TransactionDetailsRepository;

import lombok.extern.log4j.Log4j2;

@Service
@Log4j2
public class PaymentServiceImpl implements PaymentService {

    @Autowired
    private TransactionDetailsRepository transactionDetailsRepository;

    @Override
    public long doPayment(PaymentRequest request) {

        log.info("Recording payment details: {}", request);

        TransactionDetails transactionDetails = TransactionDetails.builder()
                .orderId(request.getOrderId())
                .amount(request.getAmount())
                .referenceNumber(request.getReferenceNumber())
                .paymentMode(request.getPaymentMode().name())
                .paymentStatus("SUCCESS")
                .paymentDate(Instant.now())
                .build();

        transactionDetailsRepository.save(transactionDetails);

        log.info("Payment details recorded successfully for order ID: {}", transactionDetails.getId());

        return transactionDetails.getId();
    }

    @Override
    public PaymentResponse getDetailByOrderId(String orderId) {
        log.info("Fetching payment details for order ID: {}", orderId);

        TransactionDetails transactionDetails = transactionDetailsRepository.findByOrderId(Long.valueOf(orderId));

        if (transactionDetails == null) {
            log.warn("No payment details found for order ID: {}", orderId);
            return null;
        }

        PaymentResponse response = PaymentResponse.builder()
                .paymentId(transactionDetails.getId())
                .status(transactionDetails.getPaymentStatus())
                .paymentMode(PaymentMode.valueOf(transactionDetails.getPaymentMode()))
                .amount(transactionDetails.getAmount())
                .paymentDate(transactionDetails.getPaymentDate())
                .orderId(transactionDetails.getOrderId())
                .build();

        log.info("Payment details fetched successfully for order ID: {}", orderId);

        return response;
    }
}