package com.termiwum.productservice.service;

import com.termiwum.productservice.model.ProductRequest;
import com.termiwum.productservice.model.ProductResponse;

public interface ProductService {
    long add(ProductRequest productRequest);

    ProductResponse getById(long id);

    void reduceQuantity(long productId, long quantity);
}
