package com.termiwum.paymentservice.service;

import java.time.Instant;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.termiwum.paymentservice.entity.TransactionDetails;
import com.termiwum.paymentservice.model.PaymentMode;
import com.termiwum.paymentservice.model.PaymentRequest;
import com.termiwum.paymentservice.model.PaymentResponse;
import com.termiwum.paymentservice.repository.TransactionDetailsRepository;

@Service
public class PaymentServiceImpl implements PaymentService {

    private static final Logger log = LoggerFactory.getLogger(PaymentServiceImpl.class);

    @Autowired
    private TransactionDetailsRepository transactionDetailsRepository;

    @Override
    public long doPayment(PaymentRequest request) {

        log.info("Recording payment details: {}", request);

        TransactionDetails transactionDetails = new TransactionDetails(
                request.orderId(),
                request.paymentMode().name(),
                request.referenceNumber(),
                Instant.now(),
                "SUCCESS",
                request.amount());

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

        PaymentResponse response = new PaymentResponse(
                transactionDetails.getId(),
                transactionDetails.getPaymentStatus(),
                PaymentMode.valueOf(transactionDetails.getPaymentMode()),
                transactionDetails.getAmount(),
                transactionDetails.getPaymentDate(),
                transactionDetails.getOrderId());

        log.info("Payment details fetched successfully for order ID: {}", orderId);

        return response;
    }
}