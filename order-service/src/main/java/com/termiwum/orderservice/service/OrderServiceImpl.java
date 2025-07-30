package com.termiwum.orderservice.service;

import java.time.Instant;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.termiwum.orderservice.entity.Order;
import com.termiwum.orderservice.exception.CustomException;
import com.termiwum.orderservice.external.client.PaymentService;
import com.termiwum.orderservice.external.client.ProductService;
import com.termiwum.orderservice.external.request.PaymentRequest;
import com.termiwum.orderservice.external.response.PaymentResponse;
import com.termiwum.orderservice.external.response.ProductResponse;
import com.termiwum.orderservice.model.OrderRequest;
import com.termiwum.orderservice.model.OrderResponse;
import com.termiwum.orderservice.repository.OrderRepository;

import lombok.extern.log4j.Log4j2;

@Service
@Log4j2
public class OrderServiceImpl implements OrderService {

        @Autowired
        private OrderRepository orderRepository;

        @Autowired
        private ProductService productService;

        @Autowired
        private PaymentService paymentService;

        @Autowired
        private RestTemplate restTemplate;

        @Value("${microservice.PRODUCT-SERVICE}")
        private String productServiceUrl;

        @Value("${microservice.PAYMENT-SERVICE}")
        private String paymentServiceUrl;

        @Override
        public long placeOrder(OrderRequest orderRequest) {
                log.info("Placing order request {}", orderRequest);

                productService.reduceQuantity(orderRequest.getProductId(), orderRequest.getQuantity());

                log.info("Creating Order With Status CREATED");

                Order order = Order.builder()
                                .amount(orderRequest.getTotalAmount())
                                .orderStatus("CREATED")
                                .productId(orderRequest.getProductId())
                                .orderDate(Instant.now())
                                .quantity(orderRequest.getQuantity())
                                .build();

                orderRepository.save(order);

                log.info("Calling Payment Service to complete the payment");
                PaymentRequest paymentRequest = PaymentRequest.builder().orderId(order.getId())
                                .paymentMode(orderRequest.getPaymentMode()).amount(orderRequest.getTotalAmount())
                                .build();

                String orderStatus = null;

                try {
                        paymentService.doPayment(paymentRequest);
                        log.info("Payment done Successfully. Changing the Order status to PLACED");
                        orderStatus = "PLACED";
                } catch (Exception e) {
                        log.error("Error occurred while processing payment. Changing the Order status to PAYMENT_FAILED");
                        orderStatus = "PAYMENT_FAILED";
                }

                order.setOrderStatus(orderStatus);
                orderRepository.save(order);

                log.info("Order placed successfully with ID: {}", order.getId());

                return order.getId();
        }

        @Override
        public OrderResponse getOrderDetails(long orderId) {
                log.info("Fetching details for order ID: {}", orderId);

                Order order = orderRepository.findById(orderId)
                                .orElseThrow(() -> new CustomException("Order not found for order ID: " + orderId,
                                                "NOT_FOUND", 404));

                log.info("Invoking Product service to fetch the product for id: {}", order.getProductId());
                ProductResponse productReponse = restTemplate.getForObject(
                                productServiceUrl + order.getProductId(),
                                ProductResponse.class);

                log.info("Getting payment information form the payment service");
                PaymentResponse paymentResponse = restTemplate.getForObject(
                                paymentServiceUrl + "orders/" + order.getId(),
                                PaymentResponse.class);

                OrderResponse.ProductDetails productDetails = OrderResponse.ProductDetails.builder()
                                .productId(productReponse.getProductId())
                                .productName(productReponse.getProductName())
                                .build();

                OrderResponse.PaymentDetails paymentDetails = OrderResponse.PaymentDetails.builder()
                                .paymentId(paymentResponse.getPaymentId())
                                .paymentMode(paymentResponse.getPaymentMode())
                                .paymentStatus(paymentResponse.getStatus())
                                .paymentDate(paymentResponse.getPaymentDate())
                                .build();

                OrderResponse orderResponse = OrderResponse.builder()
                                .orderId(order.getId())
                                .orderDate(order.getOrderDate())
                                .orderStatus(order.getOrderStatus())
                                .amount(order.getAmount())
                                .productDetails(productDetails)
                                .paymentDetails(paymentDetails)
                                .build();

                return orderResponse;
        }

}
