package com.termiwum.productservice.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.termiwum.productservice.entity.Product;
import com.termiwum.productservice.exception.CustomException;
import com.termiwum.productservice.model.ProductRequest;
import com.termiwum.productservice.model.ProductResponse;
import com.termiwum.productservice.repository.ProductRepository;

import lombok.extern.log4j.Log4j2;
import static org.springframework.beans.BeanUtils.copyProperties;

@Service
@Log4j2
public class ProductServiceImpl implements ProductService {

    @Autowired
    private ProductRepository productRepository;

    @Override
    public long add(ProductRequest productRequest) {
        log.info("adding product..");

        Product product = Product.builder()
                .productName(productRequest.getName())
                .price(productRequest.getPrice())
                .quantity(productRequest.getQuantity()).build();

        log.info("product created.");

        productRepository.save(product);
        return product.getProductId();
    }

    @Override
    public ProductResponse findOne(long id) {
        log.info("finding product..");
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new CustomException("Product not found with id: " + id, "PRODUCT_NOT_FOUND",
                        HttpStatus.NOT_FOUND.value()));

        ProductResponse productResponse = new ProductResponse();

        copyProperties(product, productResponse);
        log.info("product found.");
        return productResponse;

    }

    @Override
    public void reduceQuantity(long productId, long quantity) {
        log.info("reducing product quantity {} for id: {}", quantity, productId);
        Product product = productRepository.findById(productId)
                .orElseThrow(
                        () -> new CustomException("Product not found with id: " + productId, "PRODUCT_NOT_FOUND",
                                HttpStatus.NOT_FOUND.value()));

        if (product.getQuantity() < quantity) {
            throw new CustomException("Insufficient product quantity for id: " + productId, "INSUFFICIENT_QUANTITY",
                    HttpStatus.BAD_REQUEST.value());
        }

        product.setQuantity(product.getQuantity() - quantity);
        productRepository.save(product);
        log.info("product quantity reduced successfully.");

    }
}