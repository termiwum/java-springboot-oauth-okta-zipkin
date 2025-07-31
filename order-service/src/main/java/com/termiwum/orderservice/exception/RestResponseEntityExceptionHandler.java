package com.termiwum.orderservice.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import lombok.extern.log4j.Log4j2;

import com.termiwum.orderservice.external.response.ErrorResponse;

@ControllerAdvice
@Log4j2
public class RestResponseEntityExceptionHandler {

        public ResponseEntity<ErrorResponse> handleCustomException(CustomException exception) {
                log.info("Handling CustomException: {} | Code: {} | Status: {}", exception.getMessage(),
                                exception.getErrorCode(), exception.getStatus());
                return new ResponseEntity<>(
                                ErrorResponse.builder()
                                                .errorMessage(exception.getMessage())
                                                .errorCode(exception.getErrorCode())
                                                .build(),
                                HttpStatus.valueOf(exception.getStatus()));
        }
}
