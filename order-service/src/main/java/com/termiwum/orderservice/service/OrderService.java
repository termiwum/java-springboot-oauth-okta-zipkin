package com.termiwum.orderservice.service;

import com.termiwum.orderservice.model.OrderRequest;
import com.termiwum.orderservice.model.OrderResponse;

public interface OrderService {

    long placeOrder(OrderRequest orderRequest);

    OrderResponse getOrderDetails(long orderId);
}