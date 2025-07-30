package com.termiwum.cloudgateway.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class FallbackController {

    @RequestMapping("/orderServiceFallback")
    public String orderServiceFallback() {
        return "El servicio de órdenes no está disponible. Por favor, inténtalo más tarde.";
    }

    @RequestMapping("/paymentServiceFallback")
    public String paymentServiceFallback() {
        return "El servicio de pagos no está disponible. Por favor, inténtalo más tarde.";
    }

    @RequestMapping("/productServiceFallback")
    public String productServiceFallback() {
        return "El servicio de productos no está disponible. Por favor, inténtalo más tarde.";
    }

}
